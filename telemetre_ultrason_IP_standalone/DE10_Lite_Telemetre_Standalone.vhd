library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DE10_Lite_Telemetre_Standalone is
    port(
        -- 时钟和复位
        MAX10_CLK1_50 : in  std_logic;
        KEY0          : in  std_logic;
        
        -- LED显示距离
        LEDR          : out std_logic_vector(9 downto 0);
        
        -- 超声波传感器接口
        GPIO_1        : out std_logic;  -- Trig
        GPIO_3        : in  std_logic   -- Echo
    );
end entity;

architecture arch of DE10_Lite_Telemetre_Standalone is
    
    -- 实例化超声波模块
    component telemetre_ultrason_HC_SR04_IP is
        port(
            clk     : in  std_logic;
            rst_n   : in  std_logic;
            echo    : in  std_logic;
            trig    : out std_logic;
            dist_cm : out std_logic_vector(9 downto 0)
        );
    end component;
    
begin

    -- 超声波模块实例化
    Ultrasonic_Inst : telemetre_ultrason_HC_SR04_IP
        port map(
            clk     => MAX10_CLK1_50,  -- 50MHz时钟
            rst_n   => KEY0,           -- 按键0作为复位
            echo    => GPIO_3,         -- Echo信号
            trig    => GPIO_1,         -- Trig信号
            dist_cm => LEDR            -- 距离显示在LED上
        );

end architecture;