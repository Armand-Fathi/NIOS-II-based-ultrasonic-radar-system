library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_telemetre_ultrason_avec_avalon is
end entity;

architecture tb_telemetre_ultrason_avec_avalon_arch of tb_telemetre_ultrason_avec_avalon is
    -- 基本信号
    signal Tclk, Trst_n, Techo, Ttrig : std_logic := '0';
    signal Tdist_cm : std_logic_vector(9 downto 0);
    
    -- Avalon总线信号
    signal TRead_n, Tchipselect : std_logic := '1';
    signal Treaddata : std_logic_vector(31 downto 0);
    
    -- 测试控制信号
    signal OK : boolean := true;
    signal Done : boolean := false;
    
    constant CLK_PERIOD : time := 20 ns; -- 50MHz
    
begin
    -- Device Under Test (使用带Avalon接口的版本)
    DUT: entity work.telemetre_ultrason_HC_SR04_IP_avec_Avalon
        port map(
            clk => Tclk,
            rst_n => Trst_n,
            echo => Techo,
            trig => Ttrig,
            dist_cm => Tdist_cm,
            Read_n => TRead_n,
            chipselect => Tchipselect,
            readdata => Treaddata
        );
    
    -- Clock generation with Done control
    Tclk <= not Tclk after CLK_PERIOD/2 when not Done else '0';
    
    -- 主测试过程 - 包含距离测量和Avalon总线测试
    process
        variable expected_dist : integer;
        variable echo_cycles : integer;
        variable read_value : integer;
    begin
        -- Initialize
        Trst_n <= '0';
        Techo <= '0';
        Tchipselect <= '0';
        TRead_n <= '1';
        wait for 100 ns;
        Trst_n <= '1';
        
        report "=== DISTANCE MEASUREMENT TEST START ===";
        
        -- Test 1: 20cm distance
        report "Test 1: 20cm distance";
        wait until Ttrig = '1';
        wait until Ttrig = '0';
        wait for 1 us;
        echo_cycles := 20 * 2941; -- 20cm in cycles
        Techo <= '1';
        wait for echo_cycles * CLK_PERIOD;
        Techo <= '0';
        
        -- Wait for echo lock and distance calculation
        wait for 10 us;
        
        expected_dist := 20;
        if to_integer(unsigned(Tdist_cm)) /= expected_dist then
            OK <= false;
            report "Distance Test 1 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Distance Test 1: 20cm distance - OK";
        end if;
        
        -- Avalon总线测试 - 使用刚刚测量的20cm
        report "=== AVALON BUS TEST START ===";
        
        -- Test Avalon 1: 正常读取
        report "Avalon Test 1: Normal Avalon read";
        wait until rising_edge(Tclk);
        Tchipselect <= '1';
        TRead_n <= '0';
        wait until rising_edge(Tclk);
        wait until rising_edge(Tclk);
        
        read_value := to_integer(unsigned(Treaddata(9 downto 0)));
        if read_value /= to_integer(unsigned(Tdist_cm)) then
            OK <= false;
            report "Avalon Test 1 FAILED: Treaddata=" & integer'image(read_value) & 
                   ", Tdist_cm=" & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Avalon Test 1: Normal read - OK, Distance=" & integer'image(read_value) & "cm";
        end if;
        
        Tchipselect <= '0';
        TRead_n <= '1';
        wait for 1 us;
        
        -- Test Avalon 2: chipselect无效时的读取
        report "Avalon Test 2: Read with chipselect=0";
        TRead_n <= '0';
        Tchipselect <= '0';
        wait until rising_edge(Tclk);
        wait until rising_edge(Tclk);
        
        if Treaddata /= "00000000000000000000000000000000" then
            OK <= false;
            report "Avalon Test 2 FAILED: readdata should be 0 when chipselect=0" severity error;
        else
            report "Avalon Test 2: chipselect=0 read - OK";
        end if;
        
        TRead_n <= '1';
        wait for 1 us;
        
        -- Test Avalon 3: Read_n无效时的读取
        report "Avalon Test 3: Read with Read_n=1";
        Tchipselect <= '1';
        TRead_n <= '1';
        wait until rising_edge(Tclk);
        wait until rising_edge(Tclk);
        
        if Treaddata /= "00000000000000000000000000000000" then
            OK <= false;
            report "Avalon Test 3 FAILED: readdata should be 0 when Read_n=1" severity error;
        else
            report "Avalon Test 3: Read_n=1 read - OK";
        end if;
        
        Tchipselect <= '0';
        wait for 1 us;
        
        report "=== AVALON BUS TEST COMPLETED ===";
        
        -- 继续距离测量测试
        wait for 60 ms; -- 等待完整测量周期
        
        -- Test 2: 50cm distance  
        report "Test 2: 50cm distance";
        wait until Ttrig = '1';
        wait until Ttrig = '0';
        wait for 1 us;
        echo_cycles := 50 * 2941; -- 50cm in cycles
        Techo <= '1';
        wait for echo_cycles * CLK_PERIOD;
        Techo <= '0';
        
        -- Wait for echo lock and distance calculation
        wait for 10 us;
        
        expected_dist := 50;
        if to_integer(unsigned(Tdist_cm)) /= expected_dist then
            OK <= false;
            report "Distance Test 2 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Distance Test 2: 50cm distance - OK";
        end if;
        wait for 60 ms;
        
        -- Test 3: No echo (object too far)
        report "Test 3: No echo";
        wait until Ttrig = '1';
        wait until Ttrig = '0';
        -- No echo signal
        wait for 60 ms;
        
        expected_dist := 0;
        if to_integer(unsigned(Tdist_cm)) /= expected_dist then
            OK <= false;
            report "Distance Test 3 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Distance Test 3: No echo - OK";
        end if;
        wait for 60 ms;
        
        -- Test 4: Maximum distance (400cm)
        report "Test 4: Maximum distance 400cm";
        wait until Ttrig = '1';
        wait until Ttrig = '0';
        wait for 1 us;
        echo_cycles := 400 * 2941; -- 400cm in cycles
        Techo <= '1';
        wait for echo_cycles * CLK_PERIOD;
        Techo <= '0';
        wait for 60 ms;
        
        expected_dist := 400;
        if to_integer(unsigned(Tdist_cm)) /= expected_dist then
            OK <= false;
            report "Distance Test 4 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Distance Test 4: Maximum distance - OK";
        end if;
        wait for 60 ms;
        
        -- Test 5: Reset during measurement
        report "Test 5: Reset during measurement";
        wait until Ttrig = '1';
        wait until Ttrig = '0';
        wait for 1 us;
        echo_cycles := 100 * 2941; -- 100cm in cycles
        Techo <= '1';
        wait for echo_cycles * CLK_PERIOD / 2; -- Halfway through echo
        Trst_n <= '0'; -- Reset during echo
        wait for 100 ns;
        Trst_n <= '1';
        wait for 60 ms;
        
        expected_dist := 0; -- Should be reset to 0
        if to_integer(unsigned(Tdist_cm)) /= expected_dist then
            OK <= false;
            report "Distance Test 5 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Distance Test 5: Reset during measurement - OK";
        end if;
        wait for 60 ms;
        
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