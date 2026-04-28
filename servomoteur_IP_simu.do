vlib work

vcom -2008 ../miniprojet/servomoteur_IP.vhd
vcom -2008 ../miniprojet/tb_servomoteur_IP.vhd

vsim tb_servomoteur_IP

add wave *

run -all