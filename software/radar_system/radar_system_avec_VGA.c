#include <stdio.h>
#include <unistd.h>
#include <math.h>       // 编译时需加 -lm
#include "system.h"
#include "io.h"

// --- 硬件地址映射 ---
#define VGA_BASE      ONCHIP_SRAM_BASE
#define TELEMETRE_ADDR TELEMETRE_ULTRASON_HC_SR04_IP_AVEC_AVALON_0_BASE
#define SM_ADDR        SERVOMOTEUR_IP_AVEC_AVALON_0_BASE

// --- VGA 参数 (160x120 模式) ---
#define SCREEN_WIDTH  160
#define SCREEN_HEIGHT 120
#define CENTER_X      80
#define MAX_Y         119

// --- 颜色定义 ---
#define BLACK   0x0000
#define RED     0xF800
#define GREEN   0x07E0

#define PI 3.1415926535

// --- 形状修正系数 ---
// 如果圆看起来扁（太宽），把这个数改小（例如 0.75）
// 如果圆看起来瘦（太高），把这个数改大（例如 1.25）
// 建议从 0.8 开始尝试
#define X_SCALE  0.8

// --- VGA 绘图函数 ---

void draw_pixel(int x, int y, short color) {
    if (x < 0 || x >= SCREEN_WIDTH || y < 0 || y >= SCREEN_HEIGHT) {
        return;
    }
    int offset = (y << 9) + (x << 1);
    IOWR_16DIRECT(VGA_BASE, offset, color);
}

void clear_screen() {
    int x, y;
    for (y = 0; y < SCREEN_HEIGHT; y++) {
        for (x = 0; x < SCREEN_WIDTH; x++) {
            draw_pixel(x, y, BLACK);
        }
    }
}

// 绘制雷达扫描线 (带形状修正)
void draw_radar_line(unsigned int angle, unsigned int dist_obj_cm) {
    int r;
    int x, y;
    double rad;

    // 将角度转换为弧度
    rad = (double)angle * PI / 180.0;

    // 半径保持 75
    int max_display_radius = 75;

    // 遍历半径 r
    for (r = 0; r < max_display_radius; r++) {

        // --- 核心修改在这里 ---
        // 在计算 X 时乘以 X_SCALE 进行压缩或拉伸
        // 注意：要先转成 double 运算，最后再转回 int
        x = CENTER_X - (int)(r * X_SCALE * cos(rad));

        // Y 轴保持不变
        y = MAX_Y - (int)(r * sin(rad));

        // 绘制逻辑
        if (r < dist_obj_cm) {
            draw_pixel(x, y, GREEN);
        }
        else {
            draw_pixel(x, y, RED);
        }
    }
}

// --- 七段数码管 ---
void display_on_7seg(unsigned int distance) {
    const unsigned char seg7_codes[10] = {
        0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
    };
    if (distance > 999) distance = 999;
    unsigned int hundreds = distance / 100;
    unsigned int tens = (distance % 100) / 10;
    unsigned int units = distance % 10;
    IOWR(HEX3_HEX0_BASE, 0, (seg7_codes[hundreds] << 16) | (seg7_codes[tens] << 8) | seg7_codes[units]);
}

// --- 主函数 ---
int main()
{
    unsigned int degree = 0;
    int direction = 1;
    unsigned int distance;

    printf("Radar System (Corrected Aspect Ratio)...\n");

    clear_screen();

    while(1){
        IOWR(SM_ADDR, 0, degree);
        distance = IORD(TELEMETRE_ADDR, 0);

        // 终端显示
        printf("Deg: %d, Dist: %d cm\n", degree, distance);

        display_on_7seg(distance);

        draw_radar_line(degree, distance);

        if(degree < 180 && direction == 1)      ++degree;
        else if(degree == 180 && direction == 1) { --degree; direction = 0; }
        else if(degree > 0 && direction == 0)    --degree;
        else if(degree == 0 && direction == 0)   { ++degree; direction = 1; }

        usleep(30000);
    }
    return 0;
}
