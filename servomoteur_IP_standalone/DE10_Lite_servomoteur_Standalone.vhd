library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DE10_Lite_Servomoteur_Standalone is
    port(
        -- 时钟和复位
        MAX10_CLK1_50 : in  std_logic;
        KEY0          : in  std_logic;
        
        -- 位置控制开关
        SW            : in  std_logic_vector(9 downto 0);
        
        -- 舵机控制接口
        GPIO_0        : out std_logic  -- Commande (PWM输出)
    );
end entity;

architecture arch of DE10_Lite_Servomoteur_Standalone is
    
    -- 实例化舵机模块
    component servomoteur_IP is
        port(
            clk      : in  std_logic;
            rst_n    : in  std_logic;
            position : in  std_logic_vector(9 downto 0);
            commande : out std_logic
        );
    end component;
    
begin

    -- 舵机模块实例化
    Servo_Inst : servomoteur_IP
        port map(
            clk      => MAX10_CLK1_50,  -- 50MHz时钟
            rst_n    => KEY0,           -- 按键0作为复位
            position => SW,             -- 开关控制位置 (0-180度)
            commande => GPIO_0          -- PWM信号输出到舵机
        );

end architecture;