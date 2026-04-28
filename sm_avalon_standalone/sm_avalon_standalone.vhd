library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sm_avalon_standalone is
    port(
        -- 时钟和复位
        MAX10_CLK1_50 : in  std_logic;
        KEY0          : in  std_logic;
        
        -- 位置控制开关
        SW            : in  std_logic_vector(9 downto 0);
        
        -- 舵机控制接口
        GPIO_0        : out std_logic;  -- Commande (PWM输出)
        
        -- 调试LED
        LEDR          : out std_logic_vector(9 downto 0)
    );
end entity;

architecture arch of sm_avalon_standalone is
    
    -- 实例化舵机模块
    component servomoteur_IP_avec_Avalon is
        port(
            clk         : in  std_logic;
            rst_n       : in  std_logic;
            chipselect  : in  std_logic;
            write_n     : in  std_logic;
            WriteData   : in  std_logic_vector(31 downto 0);
            commande    : out std_logic
        );
    end component;
    
    -- 内部信号
    signal chipselect_sig : std_logic := '1';  -- 始终选中
    signal write_n_sig    : std_logic := '0';  -- 始终允许写入
    signal write_data_sig : std_logic_vector(31 downto 0);
    
begin

    -- 将开关值映射到32位WriteData
    -- SW[9:0] 直接作为角度值 (0-180)
    write_data_sig <= "0000000000000000000000" & SW(9 downto 0) when unsigned(SW) <= 180 else
                     "00000000000000000000000010110100";  -- 180的二进制
    
    -- 在LED上显示当前角度值（低8位）
    LEDR(7 downto 0) <= SW(7 downto 0) when unsigned(SW) <= 180 else
                       "10110100";  -- 180的二进制
    
    -- LED[9:8] 用于状态指示
    LEDR(9) <= '1';  -- 电源指示
    LEDR(8) <= not KEY0;  -- 复位状态指示

    -- 舵机模块实例化
    Servo_Inst : servomoteur_IP_avec_Avalon
        port map(
            clk         => MAX10_CLK1_50,     -- 50MHz时钟
            rst_n       => KEY0,              -- 按键0作为复位（低电平有效）
            chipselect  => chipselect_sig,    -- 始终选中
            write_n     => write_n_sig,       -- 始终允许写入
            WriteData   => write_data_sig,    -- 来自开关的角度数据
            commande    => GPIO_0             -- PWM信号输出到舵机
        );

end architecture;