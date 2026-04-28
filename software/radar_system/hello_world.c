#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"

#define TELEMETRE_ADDR TELEMETRE_ULTRASON_HC_SR04_IP_AVEC_AVALON_0_BASE
#define SM_ADDR SERVOMOTEUR_IP_AVEC_AVALON_0_BASE

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

int main()
{
  unsigned int degree=0;
  int direction=1; //1：增，0：减
  unsigned int distance;

  while(1){
	  IOWR(SM_ADDR, 0, degree);
	  distance=IORD(TELEMETRE_ADDR, 0);
      // 在终端显示
      printf("distance: %d cm，degree：%d\n",distance ,degree);
      fflush(stdout); // 刷新输出缓冲区
      // 在七段数码管上显示距离
      display_on_7seg(distance);

      if(degree<180 && direction==1)
    	  ++degree;
      else if(degree==180 && direction==1){
    	  --degree;
    	  direction=0;
      }
      else if(degree>0 && direction==0)
    	  --degree;
      else if(degree==0 && direction==0){
    	  ++degree;
    	  direction=1;
      }

      usleep(100000);
  }


  return 0;
}
