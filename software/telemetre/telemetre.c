#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

// 七段数码管显示函数
void display_on_7seg(unsigned int distance) {
    // 数码管编码表 (共阴极，0-9)
    const unsigned char seg7_codes[10] = {
        0x3F, // 0
        0x06, // 1
        0x5B, // 2
        0x4F, // 3
        0x66, // 4
        0x6D, // 5
        0x7D, // 6
        0x07, // 7
        0x7F, // 8
        0x6F  // 9
    };
    
    unsigned int hundreds = distance / 100;
    unsigned int tens = (distance % 100) / 10;
    unsigned int units = distance % 10;
    
    // 显示在HEX2, HEX1, HEX0上
    IOWR(HEX3_HEX0_BASE, 0, 
         (seg7_codes[hundreds] << 16) | 
         (seg7_codes[tens] << 8) | 
         seg7_codes[units]);
}

int main() {
    printf("=== 超声波测距测试程序 ===\n");
    printf("读取超声波传感器数据...\n\n");
    
    while(1) {
        // 读取超声波传感器数据
        unsigned int distance = IORD(TELEMETRE_ULTRASON_HC_SR04_IP_AVEC_AVALON_0_BASE, 0);
        
        // 由于距离值是10位的，我们取低10位
        distance = distance & 0x3FF;
        
        // 在终端显示距离
        printf("距离: %3d cm\r", distance);
        fflush(stdout); // 刷新输出缓冲区
        
        // 在七段数码管上显示距离
        display_on_7seg(distance);
        
        // 延时100ms
        usleep(100000);
    }
    
    return 0;
}
