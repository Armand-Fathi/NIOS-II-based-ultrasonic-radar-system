vlib work

vcom -2008 ../miniprojet/servomoteur_IP_avec_Avalon.vhd
vcom -2008 ../miniprojet/tb_servomoteur_IP_avec_Avalon.vhd

vsim tb_servomoteur_IP_avec_Avalon

add wave *

run -all