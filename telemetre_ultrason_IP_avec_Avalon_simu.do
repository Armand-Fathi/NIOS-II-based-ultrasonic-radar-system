vlib work

vcom -2008 ../miniprojet/telemetre_ultrason_HC_SR04_IP_avec_Avalon.vhd
vcom -2008 ../miniprojet/tb_telemetre_ultrason_HC_SR04_IP_avec_Avalon.vhd

vsim tb_telemetre_ultrason_avec_avalon

add wave *

run -all