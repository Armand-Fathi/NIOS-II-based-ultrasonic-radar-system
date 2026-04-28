vlib work

vcom -2008 ../telemetre_ultrason_IP_standalone/telemetre_ultrason_HC_SR04_IP.vhd
vcom -2008 ../telemetre_ultrason_IP_standalone/tb_telemetre_ultrason_HC_SR04_IP.vhd

vsim tb_telemetre_ultrason

add wave *

run -all