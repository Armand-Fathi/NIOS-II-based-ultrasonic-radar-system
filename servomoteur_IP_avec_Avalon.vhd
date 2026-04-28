library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity servomoteur_IP_avec_Avalon is
    port(
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        chipselect  : in  std_logic;
        write_n     : in  std_logic;
        WriteData   : in  std_logic_vector(31 downto 0);
        commande    : out std_logic
    );
end entity;

architecture servomoteur_IP_avec_Avalon_arch of servomoteur_IP_avec_Avalon is
    type state_type is (HIGHSTATE, LOWSTATE);
    signal state : state_type := HIGHSTATE;
    
    -- 基于CLK_FREQ计算参数
    constant CLK_FREQ : integer := 100000000;     -- 100MHz
    constant PERIOD_20MS : integer := CLK_FREQ / 50;   -- 15ms周期 (改为15ms)
    constant MIN_PULSE : integer := CLK_FREQ / 2000;   -- 0.5ms
    constant MAX_PULSE : integer := CLK_FREQ / 400;    -- 2.5ms
    
    -- 内部信号
    signal position_reg : std_logic_vector(31 downto 0) := (others => '0');
    
begin
    -- Avalon总线写入处理：更新位置寄存器
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            position_reg <= (others => '0');
        elsif rising_edge(clk) then
            if chipselect = '1' and write_n = '0' then
                position_reg <= WriteData;  -- 存储位置值（角度数，0-180度）
            end if;
        end if;
    end process;

    -- 伺服电机PWM生成（主状态机）
    process(clk, rst_n)
        variable counter : unsigned(31 downto 0) := (others => '0');
        variable period_counter : unsigned(31 downto 0) := (others => '0');
        variable pulse_width : integer := 0;
    begin
        if rst_n = '0' then
            commande <= '0';
            counter := (others => '0');
            period_counter := (others => '0');
            state <= HIGHSTATE;
            
        elsif rising_edge(clk) then
            -- 计算脉冲宽度：使用存储的位置值
            pulse_width := MIN_PULSE + (to_integer(unsigned(position_reg)) * (MAX_PULSE - MIN_PULSE)) / 180;
            
            -- 限制脉冲宽度在有效范围内
            if pulse_width < MIN_PULSE then
                pulse_width := MIN_PULSE;
            elsif pulse_width > MAX_PULSE then
                pulse_width := MAX_PULSE;
            end if;
            
            case state is
                when HIGHSTATE =>
                    commande <= '1';
                    counter := counter + 1;
                    period_counter := period_counter + 1;
                    
                    if counter >= pulse_width then
                        counter := (others => '0');
                        state <= LOWSTATE;
                    end if;
                    
                when LOWSTATE =>
                    commande <= '0';
                    period_counter := period_counter + 1;
                    
                    if period_counter >= PERIOD_20MS then
                        period_counter := (others => '0');
                        counter := (others => '0');
                        state <= HIGHSTATE;
                    end if;
            end case;
        end if;
    end process;
end architecture;