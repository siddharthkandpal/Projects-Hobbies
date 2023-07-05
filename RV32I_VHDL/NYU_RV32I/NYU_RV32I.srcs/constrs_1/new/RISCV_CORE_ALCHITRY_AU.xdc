## This is the constraints file for the FPGA board we are using, :
## Alchitry Au FPGA Development Board ( Xilinx Artix 7 XC7A35T-1C )
## https://www.sparkfun.com/products/16527 

## Original constraint obtained from alchitry's base project, license (on-board IO mapping only):
## MIT License

## Copyright (c) 2019 alchitry

## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:

## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.

## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR NO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]

create_clock -period 10.000 -name i_clk -waveform {0.000 5.000} [get_ports i_clk]
set_property PACKAGE_PIN N14 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]

#set_property PACKAGE_PIN P6 [get_ports rst_n]
#set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

###########################################################################
###########################################################################
###########################################################################
###########################################################################

set_property PACKAGE_PIN K13 [get_ports {o_output_leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[0]}]

set_property PACKAGE_PIN K12 [get_ports {o_output_leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[1]}]

set_property PACKAGE_PIN L14 [get_ports {o_output_leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[2]}]

set_property PACKAGE_PIN L13 [get_ports {o_output_leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[3]}]

set_property PACKAGE_PIN M16 [get_ports {o_output_leds[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[4]}]

set_property PACKAGE_PIN M14 [get_ports {o_output_leds[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[5]}]

set_property PACKAGE_PIN M12 [get_ports {o_output_leds[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[6]}]

set_property PACKAGE_PIN N16 [get_ports {o_output_leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[7]}]

###########################################################################
###########################################################################
###########################################################################
###########################################################################

## serial names are flipped in the schematic (named for the FTDI chip)
#set_property PACKAGE_PIN P16 [get_ports {usb_tx}]
#set_property IOSTANDARD LVCMOS33 [get_ports {usb_tx}]

#set_property PACKAGE_PIN P15 [get_ports {usb_rx}]
#set_property IOSTANDARD LVCMOS33 [get_ports {usb_rx}]

###########################################################################
###########################################################################
###########################################################################
###########################################################################

set_property PACKAGE_PIN C6 [get_ports {i_rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_rst}]
set_property PULLDOWN true [get_ports {i_rst}]

#set_property PACKAGE_PIN A7 [get_ports {io_button[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_button[1]}]
#set_property PULLDOWN true [get_ports {io_button[1]}]

#set_property PACKAGE_PIN P11 [get_ports {io_button[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_button[2]}]
#set_property PULLDOWN true [get_ports {io_button[2]}]

#set_property PACKAGE_PIN B7 [get_ports {io_button[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_button[3]}]
#set_property PULLDOWN true [get_ports {io_button[3]}]

#set_property PACKAGE_PIN C7 [get_ports {io_button[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_button[4]}]
#set_property PULLDOWN true [get_ports {io_button[4]}]

###########################################################################
###########################################################################
###########################################################################
###########################################################################

set_property PACKAGE_PIN L2 [get_ports {o_output_leds[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[8]}]

set_property PACKAGE_PIN L3 [get_ports {o_output_leds[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[9]}]

set_property PACKAGE_PIN J1 [get_ports {o_output_leds[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[10]}]

set_property PACKAGE_PIN K1 [get_ports {o_output_leds[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[11]}]

set_property PACKAGE_PIN H1 [get_ports {o_output_leds[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[12]}]

set_property PACKAGE_PIN H2 [get_ports {o_output_leds[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[13]}]

set_property PACKAGE_PIN G1 [get_ports {o_output_leds[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[14]}]

set_property PACKAGE_PIN G2 [get_ports {o_output_leds[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[15]}]

set_property PACKAGE_PIN K5 [get_ports {o_output_leds[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[16]}]

set_property PACKAGE_PIN E6 [get_ports {o_output_leds[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[17]}]

set_property PACKAGE_PIN D1 [get_ports {o_output_leds[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[18]}]

set_property PACKAGE_PIN E2 [get_ports {o_output_leds[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[19]}]

set_property PACKAGE_PIN A2 [get_ports {o_output_leds[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[20]}]

set_property PACKAGE_PIN B2 [get_ports {o_output_leds[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[21]}]

set_property PACKAGE_PIN E1 [get_ports {o_output_leds[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[22]}]

set_property PACKAGE_PIN F2 [get_ports {o_output_leds[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[23]}]

set_property PACKAGE_PIN F3 [get_ports {o_output_leds[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[24]}]

set_property PACKAGE_PIN F4 [get_ports {o_output_leds[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[25]}]

set_property PACKAGE_PIN A3 [get_ports {o_output_leds[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[26]}]

set_property PACKAGE_PIN B4 [get_ports {o_output_leds[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[27]}]

set_property PACKAGE_PIN A4 [get_ports {o_output_leds[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[28]}]

set_property PACKAGE_PIN A5 [get_ports {o_output_leds[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[29]}]

set_property PACKAGE_PIN B5 [get_ports {o_output_leds[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[30]}]

set_property PACKAGE_PIN B6 [get_ports {o_output_leds[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_output_leds[31]}]

###########################################################################
###########################################################################
###########################################################################
###########################################################################

set_property PACKAGE_PIN K2 [get_ports {i_input_switches[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[0]}]
set_property PULLDOWN true [get_ports {i_input_switches[0]}]

set_property PACKAGE_PIN K3 [get_ports {i_input_switches[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[1]}]
set_property PULLDOWN true [get_ports {i_input_switches[1]}]

set_property PACKAGE_PIN J4 [get_ports {i_input_switches[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[2]}]
set_property PULLDOWN true [get_ports {i_input_switches[2]}]

set_property PACKAGE_PIN J5 [get_ports {i_input_switches[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[3]}]
set_property PULLDOWN true [get_ports {i_input_switches[3]}]

set_property PACKAGE_PIN H3 [get_ports {i_input_switches[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[4]}]
set_property PULLDOWN true [get_ports {i_input_switches[4]}]

set_property PACKAGE_PIN J3 [get_ports {i_input_switches[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[5]}]
set_property PULLDOWN true [get_ports {i_input_switches[5]}]

set_property PACKAGE_PIN H4 [get_ports {i_input_switches[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[6]}]
set_property PULLDOWN true [get_ports {i_input_switches[6]}]

set_property PACKAGE_PIN H5 [get_ports {i_input_switches[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[7]}]
set_property PULLDOWN true [get_ports {i_input_switches[8]}]

set_property PACKAGE_PIN N6 [get_ports {i_input_switches[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[8]}]
set_property PULLDOWN true [get_ports {i_input_switches[8]}]

set_property PACKAGE_PIN M6 [get_ports {i_input_switches[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[9]}]
set_property PULLDOWN true [get_ports {i_input_switches[9]}]

set_property PACKAGE_PIN B1 [get_ports {i_input_switches[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[10]}]
set_property PULLDOWN true [get_ports {i_input_switches[10]}]

set_property PACKAGE_PIN C1 [get_ports {i_input_switches[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[11]}]
set_property PULLDOWN true [get_ports {i_input_switches[11]}]

set_property PACKAGE_PIN C2 [get_ports {i_input_switches[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[12]}]
set_property PULLDOWN true [get_ports {i_input_switches[12]}]

set_property PACKAGE_PIN C3 [get_ports {i_input_switches[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[13]}]
set_property PULLDOWN true [get_ports {i_input_switches[13]}]

set_property PACKAGE_PIN D3 [get_ports {i_input_switches[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[14]}]
set_property PULLDOWN true [get_ports {i_input_switches[14]}]

set_property PACKAGE_PIN E3 [get_ports {i_input_switches[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[15]}]
set_property PULLDOWN true [get_ports {i_input_switches[15]}]

set_property PACKAGE_PIN C4 [get_ports {i_input_switches[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[16]}]
set_property PULLDOWN true [get_ports {i_input_switches[16]}]

set_property PACKAGE_PIN D4 [get_ports {i_input_switches[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[17]}]
set_property PULLDOWN true [get_ports {i_input_switches[17]}]

set_property PACKAGE_PIN G4 [get_ports {i_input_switches[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[18]}]
set_property PULLDOWN true [get_ports {i_input_switches[18]}]

set_property PACKAGE_PIN G5 [get_ports {i_input_switches[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[19]}]
set_property PULLDOWN true [get_ports {i_input_switches[19]}]

set_property PACKAGE_PIN E5 [get_ports {i_input_switches[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[20]}]
set_property PULLDOWN true [get_ports {i_input_switches[20]}]

set_property PACKAGE_PIN F5 [get_ports {i_input_switches[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[21]}]
set_property PULLDOWN true [get_ports {i_input_switches[21]}]

set_property PACKAGE_PIN D5 [get_ports {i_input_switches[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[22]}]
set_property PULLDOWN true [get_ports {i_input_switches[22]}]

set_property PACKAGE_PIN D6 [get_ports {i_input_switches[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_input_switches[23]}]
set_property PULLDOWN true [get_ports {i_input_switches[23]}]

###########################################################################
###########################################################################
###########################################################################
###########################################################################

#set_property PACKAGE_PIN P9 [get_ports {io_sel[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_sel[0]}]

#set_property PACKAGE_PIN N9 [get_ports {io_sel[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_sel[1]}]

#set_property PACKAGE_PIN R8 [get_ports {io_sel[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_sel[2]}]

#set_property PACKAGE_PIN P8 [get_ports {io_sel[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_sel[3]}]

#set_property PACKAGE_PIN T5 [get_ports {io_seg[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[0]}]

#set_property PACKAGE_PIN R5 [get_ports {io_seg[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[1]}]

#set_property PACKAGE_PIN T9 [get_ports {io_seg[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[2]}]

#set_property PACKAGE_PIN R6 [get_ports {io_seg[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[3]}]

#set_property PACKAGE_PIN R7 [get_ports {io_seg[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[4]}]

#set_property PACKAGE_PIN T7 [get_ports {io_seg[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[5]}]

#set_property PACKAGE_PIN T8 [get_ports {io_seg[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[6]}]

#set_property PACKAGE_PIN T10 [get_ports {io_seg[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {io_seg[7]}]
