#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"

#define SERVO_BASE SERVOMOTEUR_IP_AVEC_AVALON_0_BASE
#define SWITCH_BASE SLIDER_SWITCHES_BASE

// ÑÓÊ±º¯Êý
void delay_ms(int milliseconds) {
    usleep(milliseconds * 1000);
}

int main() {

    while (1) {

        alt_u32 switch_value = IORD(SWITCH_BASE, 0);
        //delay_ms(1000);
        IOWR(SERVO_BASE, 0, switch_value);
        //delay_ms(1000);
        printf("Switch value: %d\n",(int)switch_value);
    }

    return 0;
}
