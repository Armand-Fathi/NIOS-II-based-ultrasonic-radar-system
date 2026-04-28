library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_servomoteur_IP is
end entity;

architecture tb_servomoteur_IP_arch of tb_servomoteur_IP is
    -- 测试信号
    signal Tclk, Trst_n, Tcommande : std_logic := '0';
    signal Tposition : std_logic_vector(9 downto 0) := (others => '0');
    
    -- 测试控制信号
    signal OK : boolean := true;
    signal Done : boolean := false;
    
    constant CLK_PERIOD : time := 20 ns; -- 50MHz
    
begin
    -- Device Under Test
    DUT: entity work.servomoteur_IP
        port map(
            clk => Tclk,
            rst_n => Trst_n,
            position => Tposition,
            commande => Tcommande
        );
    
    -- Clock generation
    Tclk <= not Tclk after CLK_PERIOD/2 when not Done else '0';
    
    -- 主测试过程
    process
        variable pulse_start_time : time;
        variable pulse_width : time;
        variable expected_width : time;
    begin
        -- Initialize
        Trst_n <= '0';
        Tposition <= (others => '0');
        wait for 100 ns;
        Trst_n <= '1';
        
        report "=== SERVOMOTEUR IP TEST START ===";
        
        -- Test 1: 0度位置测试
        report "Test 1: 0 degree position";
        Tposition <= std_logic_vector(to_unsigned(0, 10)); -- 0度
        wait for 1 ms; -- 等待稳定
        
        -- 测量脉冲宽度
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 500 us; -- 0.5ms
        if pulse_width >= 490 us and pulse_width <= 510 us then
            report "Test 1 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~500us)";
        else
            OK <= false;
            report "Test 1 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~500us)" severity error;
        end if;
        
        -- Test 2: 90度位置测试
        report "Test 2: 90 degree position";
        Tposition <= std_logic_vector(to_unsigned(90, 10)); -- 90度
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 1500 us; -- 1.5ms
        if pulse_width >= 1490 us and pulse_width <= 1510 us then
            report "Test 2 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~1500us)";
        else
            OK <= false;
            report "Test 2 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~1500us)" severity error;
        end if;
        
        -- Test 3: 180度位置测试
        report "Test 3: 180 degree position";
        Tposition <= std_logic_vector(to_unsigned(180, 10)); -- 180度
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 2500 us; -- 2.5ms
        if pulse_width >= 2490 us and pulse_width <= 2510 us then
            report "Test 3 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~2500us)";
        else
            OK <= false;
            report "Test 3 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~2500us)" severity error;
        end if;
        
        -- Test 4: 离谱输入测试 - 超过180度
        report "Test 4: Extreme input (300 degrees - should clamp to 180)";
        Tposition <= std_logic_vector(to_unsigned(300, 10)); -- 300度，应该被限制到180度
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        -- 应该仍然是2.5ms，因为被限制了
        if pulse_width >= 2490 us and pulse_width <= 2510 us then
            report "Test 4 PASSED: Pulse width = " & time'image(pulse_width) & " (correctly clamped to 2500us)";
        else
            OK <= false;
            report "Test 4 FAILED: Pulse width = " & time'image(pulse_width) & " (expected clamping to 2500us)" severity error;
        end if;
        
        -- Test 5: 复位测试
        report "Test 5: Reset test";
        Tposition <= std_logic_vector(to_unsigned(90, 10)); -- 设置到90度
        wait for 500 us;
        Trst_n <= '0'; -- 激活复位，复位后仍是90度
        wait for 100 ns;
        
        -- 检查复位期间输出是否为0
        if Tcommande = '0' then
            report "Test 5 PASSED: Output is 0 during reset";
        else
            OK <= false;
            report "Test 5 FAILED: Output should be 0 during reset" severity error;
        end if;
        
        -- 释放复位
        Trst_n <= '1';
        wait for 1 ms;
        
        -- 验证复位后正常工作
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        if pulse_width >= 1490 us and pulse_width <= 1510 us then
            report "Test 5 PASSED: Normal operation after reset";
        else
            OK <= false;
            report "Test 5 FAILED: Abnormal operation after reset" severity error;
        end if;
        
        -- Test 6: 周期测试 - 验证20ms周期
        report "Test 6: Period test (should be ~20ms)";
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until rising_edge(Tcommande); -- 下一个上升沿
        pulse_width := now - pulse_start_time;
        
        expected_width := 20 ms;
        if pulse_width >= 19900 us and pulse_width <= 20100 us then
            report "Test 6 PASSED: Period = " & time'image(pulse_width) & " (expected ~20ms)";
        else
            OK <= false;
            report "Test 6 FAILED: Period = " & time'image(pulse_width) & " (expected ~20ms)" severity error;
        end if;
        
        -- All tests completed
        report "=== ALL TESTS COMPLETED ===";
        if OK then
            report "=== FINAL RESULT: ALL TESTS PASSED ===";
        else
            report "=== FINAL RESULT: SOME TESTS FAILED ===" severity error;
        end if;
        
        Done <= true;
        wait;
    end process;
    
end architecture;