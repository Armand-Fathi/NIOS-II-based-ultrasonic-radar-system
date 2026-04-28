--DF ROBOT
--DF9GMS
-- 0.5ms高电平对应0度
-- 1.0ms高电平对应45度
-- 1.5ms高电平对应90度
-- 2.0ms高电平对应135度
-- 2.5ms高电平对应180度

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity servomoteur_IP is
    port(
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        position : in  std_logic_vector(9 downto 0); -- 输入角度 (建议范围: 0-180)
        commande : out std_logic
    );
end entity;

architecture servomoteur_IP_arch of servomoteur_IP is
    type state_type is (HIGHSTATE, LOWSTATE);
    signal state : state_type := HIGHSTATE;
    
    -- 常量定义
    constant CLK_FREQ : integer := 50000000;     -- 50MHz
    constant PERIOD_20MS : integer := 1000000;   -- 20ms周期
    constant MIN_PULSE : integer := 25000;       -- 0.5ms
    constant MAX_PULSE : integer := 125000;      -- 2.5ms
    
begin
    process(clk, rst_n)
        variable counter : unsigned(31 downto 0) := (others => '0');
        variable period_counter : unsigned(31 downto 0) := (others => '0');
        variable pulse_width : integer := 0;
    begin
        if rst_n = '0' then
            commande <= '0';  -- 复位时输出低电平更安全
            counter := (others => '0');
            period_counter := (others => '0');
            state <= HIGHSTATE;
            
        elsif rising_edge(clk) then
            -- 计算脉冲宽度：将角度转换为脉冲宽度
            -- position输入应该是0-180，对应0°-180°
            pulse_width := MIN_PULSE + (to_integer(unsigned(position)) * (MAX_PULSE - MIN_PULSE)) / 180;
            -- 指定脉宽对应的时钟周期数
            -- 一开始就检测输入是否合法，限制脉冲宽度在有效范围内
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
                    
                    -- 使用variable实现立即状态转换
                    if counter >= pulse_width then
                        counter := (others => '0');
                        state <= LOWSTATE;
                    end if;
                    
                when LOWSTATE =>
                    commande <= '0';
                    period_counter := period_counter + 1;
                    
                    if period_counter >= PERIOD_20MS then
                        period_counter := (others => '0');
                        counter := (others => '0');  -- 重置counter
                        state <= HIGHSTATE;
                    end if;
            end case;
        end if;
    end process;
end architecture;