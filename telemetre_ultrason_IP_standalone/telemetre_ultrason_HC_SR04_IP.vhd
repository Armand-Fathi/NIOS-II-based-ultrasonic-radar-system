library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity telemetre_ultrason_HC_SR04_IP is
    port(
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        echo    : in  std_logic;
        trig    : out std_logic;
        dist_cm : out std_logic_vector(9 downto 0)
    );
end entity;

architecture telemetre_ultrason_HC_SR04_IP_arch of telemetre_ultrason_HC_SR04_IP is
    type state_type is (TRIGSTATE, MEASURESTATE);
    signal state : state_type := TRIGSTATE;
    
    signal trig_counter  : unsigned(31 downto 0) := (others => '0');
    signal total_counter : unsigned(31 downto 0) := (others => '0');
    signal echo_counter  : unsigned(31 downto 0) := (others => '0');
    signal echolock      : std_logic := '0';
    
    constant TRIG_DURATION  : unsigned(15 downto 0) := to_unsigned(500, 16);    -- 10us
    constant MEASURESTATE_TIMEOUT: unsigned(23 downto 0) := to_unsigned(3000000, 24); -- 60ms
    constant MAX_DISTANCE : unsigned(9 downto 0) := to_unsigned(400, 10); -- 最大400cm

begin 
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            trig <= '0';
            dist_cm <= (others => '0');
            trig_counter <= (others => '0');
            total_counter <= (others => '0');
            echo_counter <= (others => '0');
            echolock <= '0';
            state <= TRIGSTATE;
            
        elsif rising_edge(clk) then
            case state is
                when TRIGSTATE =>
                    -- 产生触发脉冲
                    trig <= '1';
                    trig_counter <= trig_counter + 1;
                    
                    if trig_counter >= TRIG_DURATION then
                        trig <= '0';
                        trig_counter <= (others => '0');
                        total_counter <= (others => '0');
                        echo_counter <= (others => '0');
                        echolock <= '0';
                        state <= MEASURESTATE;
                    end if;
                    
                when MEASURESTATE =>
                    -- 只在未锁定时计数第一个echo脉冲
                    if echo = '1' and echolock = '0' then
                        echo_counter <= echo_counter + 1;
                    end if;
                    
                    -- 检测第一个echo脉冲的下降沿
                    if echo = '0' and echolock = '0' and echo_counter > 0 then
                        echolock <= '1';
                        -- 距离计算：echo_counter / 2941 (50MHz时钟)
                        -- 添加最大距离限制（400cm）
                        if echo_counter > 1176400 then  -- 400cm × 2941 = 1176400
                            dist_cm <= std_logic_vector(MAX_DISTANCE);  -- 显示最大400cm
                        else
                            dist_cm <= std_logic_vector(resize(echo_counter / 2941, 10));
                        end if;
                    end if;
                    
                    -- 总时间计数
                    total_counter <= total_counter + 1;
                    
                    -- 60ms后结束测量
                    if total_counter >= MEASURESTATE_TIMEOUT then
                        -- 如果在60ms内没有检测到有效的echo，输出0
                        if echolock = '0' then
                            dist_cm <= (others => '0');
                        end if;
                        state <= TRIGSTATE;
                    end if;
            end case;
        end if;
    end process;
end architecture;