library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_servomoteur_IP_avec_Avalon is
end entity;

architecture tb_servomoteur_IP_avec_Avalon_arch of tb_servomoteur_IP_avec_Avalon is
    -- 测试信号
    signal Tclk, Trst_n, Tcommande : std_logic := '0';
    signal Tchipselect, Twrite_n : std_logic := '1';
    signal TWriteData : std_logic_vector(31 downto 0) := (others => '0');
    
    -- 测试控制信号
    signal OK : boolean := true;
    signal Done : boolean := false;
    
    constant CLK_PERIOD : time := 20 ns; -- 50MHz
    
begin
    -- Device Under Test
    DUT: entity work.servomoteur_IP_avec_Avalon
        port map(
            clk => Tclk,
            rst_n => Trst_n,
            chipselect => Tchipselect,
            write_n => Twrite_n,
            WriteData => TWriteData,
            commande => Tcommande
        );
    
    -- Clock generation
    Tclk <= not Tclk after CLK_PERIOD/2 when not Done else '0';
    
    -- 主测试过程
    process
        variable pulse_start_time : time;
        variable pulse_width : time;
        variable expected_width : time;
        variable period_start_time : time;
        variable period_width : time;
    begin
        -- Initialize
        Trst_n <= '0';
        Tchipselect <= '0';
        Twrite_n <= '1';
        TWriteData <= (others => '0');
        wait for 100 ns;
        Trst_n <= '1';
        
        report "=== SERVOMOTEUR IP WITH AVALON TEST START ===";
        
        -- Test 1: 复位后输出测试
        report "Test 1: Output after reset";
        wait for 1 ms;
        if Tcommande = '0' then
            report "Test 1 PASSED: Output is 0 after reset";
        else
            OK <= false;
            report "Test 1 FAILED: Output should be 0 after reset" severity error;
        end if;
        
        -- Test 2: 0度位置测试
        report "Test 2: 0 degree position via Avalon";
        TWriteData <= std_logic_vector(to_unsigned(0, 32));
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        Twrite_n <= '0';
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        Twrite_n <= '1';
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 500 us; -- 0.5ms
        if pulse_width >= 490 us and pulse_width <= 510 us then
            report "Test 2 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~500us)";
        else
            OK <= false;
            report "Test 2 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~500us)" severity error;
        end if;
        
        -- Test 3: 45度位置测试
        report "Test 3: 45 degree position via Avalon";
        TWriteData <= std_logic_vector(to_unsigned(45, 32));
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        Twrite_n <= '0';
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        Twrite_n <= '1';
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 1000 us; -- 1.0ms
        if pulse_width >= 990 us and pulse_width <= 1010 us then
            report "Test 3 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~1000us)";
        else
            OK <= false;
            report "Test 3 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~1000us)" severity error;
        end if;
        
        -- Test 4: 90度位置测试
        report "Test 4: 90 degree position via Avalon";
        TWriteData <= std_logic_vector(to_unsigned(90, 32));
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        Twrite_n <= '0';
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        Twrite_n <= '1';
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 1500 us; -- 1.5ms
        if pulse_width >= 1490 us and pulse_width <= 1510 us then
            report "Test 4 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~1500us)";
        else
            OK <= false;
            report "Test 4 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~1500us)" severity error;
        end if;
        
        -- Test 5: 135度位置测试
        report "Test 5: 135 degree position via Avalon";
        TWriteData <= std_logic_vector(to_unsigned(135, 32));
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        Twrite_n <= '0';
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        Twrite_n <= '1';
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 2000 us; -- 2.0ms
        if pulse_width >= 1990 us and pulse_width <= 2010 us then
            report "Test 5 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~2000us)";
        else
            OK <= false;
            report "Test 5 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~2000us)" severity error;
        end if;
        
        -- Test 6: 180度位置测试
        report "Test 6: 180 degree position via Avalon";
        TWriteData <= std_logic_vector(to_unsigned(180, 32));
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        Twrite_n <= '0';
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        Twrite_n <= '1';
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 2500 us; -- 2.5ms
        if pulse_width >= 2490 us and pulse_width <= 2510 us then
            report "Test 6 PASSED: Pulse width = " & time'image(pulse_width) & " (expected ~2500us)";
        else
            OK <= false;
            report "Test 6 FAILED: Pulse width = " & time'image(pulse_width) & " (expected ~2500us)" severity error;
        end if;
        
        -- Test 7: 边界值测试 - 超过180度
        report "Test 7: Extreme input (200 degrees - should clamp to 180)";
        TWriteData <= std_logic_vector(to_unsigned(200, 32));
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        Twrite_n <= '0';
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        Twrite_n <= '1';
        wait for 1 ms;
        
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        -- 应该仍然是2.5ms，因为被限制了
        if pulse_width >= 2490 us and pulse_width <= 2510 us then
            report "Test 7 PASSED: Pulse width = " & time'image(pulse_width) & " (correctly clamped to 2500us)";
        else
            OK <= false;
            report "Test 7 FAILED: Pulse width = " & time'image(pulse_width) & " (expected clamping to 2500us)" severity error;
        end if;
        
        -- Test 8: Avalon总线无效写入测试 - chipselect=0
        report "Test 8: Avalon invalid write (chipselect=0)";
        TWriteData <= std_logic_vector(to_unsigned(60, 32)); -- 尝试写入60度
        wait until rising_edge(Tclk);
        Twrite_n <= '0'; -- chipselect保持0
        wait until rising_edge(Tclk);
        Twrite_n <= '1';
        wait for 1 ms;
        
        -- 验证位置没有改变（应该还是180度）
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        if pulse_width >= 2490 us and pulse_width <= 2510 us then
            report "Test 8 PASSED: Position unchanged with chipselect=0";
        else
            OK <= false;
            report "Test 8 FAILED: Position changed with chipselect=0" severity error;
        end if;
        
        -- Test 9: Avalon总线无效写入测试 - write_n=1
        report "Test 9: Avalon invalid write (write_n=1)";
        TWriteData <= std_logic_vector(to_unsigned(30, 32)); -- 尝试写入30度
        wait until rising_edge(Tclk);
        Tchipselect <= '1'; -- write_n保持1
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        wait for 1 ms;
        
        -- 验证位置没有改变
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        if pulse_width >= 2490 us and pulse_width <= 2510 us then
            report "Test 9 PASSED: Position unchanged with write_n=1";
        else
            OK <= false;
            report "Test 9 FAILED: Position changed with write_n=1" severity error;
        end if;
        
        -- Test 10: 复位测试
        report "Test 10: Reset test";
        TWriteData <= std_logic_vector(to_unsigned(90, 32)); -- 设置到90度
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        Twrite_n <= '0';
        wait until rising_edge(Tclk);
        Tchipselect <= '0';
        Twrite_n <= '1';
        wait for 500 us;
        
        Trst_n <= '0'; -- 激活复位
        wait for 100 ns;
        
        -- 检查复位期间输出是否为0
        if Tcommande = '0' then
            report "Test 10 PASSED: Output is 0 during reset";
        else
            OK <= false;
            report "Test 10 FAILED: Output should be 0 during reset" severity error;
        end if;
        
        -- 释放复位
        Trst_n <= '1';
        wait for 1 ms;
        
        -- 验证复位后正常工作
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        -- 复位后应该回到0度位置
        expected_width := 500 us; -- 0.5ms
        if pulse_width >= 490 us and pulse_width <= 510 us then
            report "Test 10 PASSED: Normal operation after reset (back to 0 degrees)";
        else
            OK <= false;
            report "Test 10 FAILED: Abnormal operation after reset" severity error;
        end if;
        
        -- Test 11: 周期测试 - 验证20ms周期
        report "Test 11: Period test (should be ~20ms)";
        wait until rising_edge(Tcommande);
        period_start_time := now;
        wait until rising_edge(Tcommande); -- 下一个上升沿
        period_width := now - period_start_time;
        
        expected_width := 20 ms;
        if period_width >= 19900 us and period_width <= 20100 us then
            report "Test 11 PASSED: Period = " & time'image(period_width) & " (expected ~20ms)";
        else
            OK <= false;
            report "Test 11 FAILED: Period = " & time'image(period_width) & " (expected ~20ms)" severity error;
        end if;
        
        -- Test 12: 连续写入测试
        report "Test 12: Continuous write test";
        for i in 0 to 5 loop
            TWriteData <= std_logic_vector(to_unsigned(i * 30, 32)); -- 0, 30, 60, 90, 120, 150度
            wait until rising_edge(Tclk);
            Tchipselect <= '1';
            Twrite_n <= '0';
            wait until rising_edge(Tclk);
            Tchipselect <= '0';
            Twrite_n <= '1';
            wait for 5 ms; -- 等待部分周期
        end loop;
        
        -- 验证最后一个写入的值（150度）
        wait until rising_edge(Tcommande);
        pulse_start_time := now;
        wait until falling_edge(Tcommande);
        pulse_width := now - pulse_start_time;
        
        expected_width := 2000 us; -- 150度对应2.0ms (0.5 + 150*(2.5-0.5)/180 = 2.166ms)
        if pulse_width >= 2150 us and pulse_width <= 2170 us then
            report "Test 12 PASSED: Continuous write works correctly";
        else
            OK <= false;
            report "Test 12 FAILED: Continuous write problem" severity error;
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