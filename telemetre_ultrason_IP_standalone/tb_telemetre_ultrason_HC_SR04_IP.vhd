library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_telemetre_ultrason is
end entity;

architecture test of tb_telemetre_ultrason is
    signal Tclk, Trst_n, Techo, Ttrig : std_logic := '0';
    signal Tdist_cm : std_logic_vector(9 downto 0);
    signal OK : boolean := true;
    signal Done : boolean := false;
    
    constant CLK_PERIOD : time := 20 ns; -- 50MHz
    
begin
    -- Device Under Test
    DUT: entity work.telemetre_ultrason_HC_SR04_IP
        port map(
            clk => Tclk,
            rst_n => Trst_n,
            echo => Techo,
            trig => Ttrig,
            dist_cm => Tdist_cm
        );
    
    -- Clock generation with Done control
    Tclk <= not Tclk after CLK_PERIOD/2 when not Done else '0';
    
    -- Main test process
    process
        variable expected_dist : integer;
        variable echo_cycles : integer;
    begin
        -- Initialize
        Trst_n <= '0';
        Techo <= '0';
        wait for 100 ns;
        Trst_n <= '1';
        
        report "=== TEST START ===";
        
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
            report "Test 1 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Test 1: 20cm distance - OK";
        end if;
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
            report "Test 2 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Test 2: 50cm distance - OK";
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
            report "Test 3 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Test 3: No echo - OK";
        end if;
        wait for 60 ms;
        
        -- Test 4: Multiple echo pulses (multi-path reflection)
        report "Test 4: Multiple echo pulses";
        wait until Ttrig = '1';
        wait until Ttrig = '0';
        wait for 1 us;
        -- First echo pulse: 20cm
        echo_cycles := 20 * 2941; -- 20cm in cycles
        Techo <= '1';
        wait for echo_cycles * CLK_PERIOD;
        Techo <= '0';
        wait for 5 ms;
        -- Second echo pulse: 50cm (should be ignored)
        echo_cycles := 50 * 2941; -- 50cm in cycles
        Techo <= '1';
        wait for echo_cycles * CLK_PERIOD;
        Techo <= '0';
        wait for 60 ms;
        
        expected_dist := 20; -- Should only measure first echo
        if to_integer(unsigned(Tdist_cm)) /= expected_dist then
            OK <= false;
            report "Test 4 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Test 4: Multiple echo pulses - OK";
        end if;
        wait for 60 ms;
        
        -- Test 5: Maximum distance (400cm)
        report "Test 5: Maximum distance 400cm";
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
            report "Test 5 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Test 5: Maximum distance - OK";
        end if;
        wait for 60 ms;
        
        -- Test 6: Reset during measurement
        report "Test 6: Reset during measurement";
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
            report "Test 6 FAILED: Expected " & integer'image(expected_dist) & 
                   ", got " & integer'image(to_integer(unsigned(Tdist_cm))) severity error;
        else
            report "Test 6: Reset during measurement - OK";
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
    
end architecture test;