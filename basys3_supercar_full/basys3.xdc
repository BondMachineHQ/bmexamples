## FPGA VGA Graphics Part 1: Basys 3 Board Constraints
## Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

## Clock
set_property -dict {PACKAGE_PIN W5  IOSTANDARD LVCMOS33} [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

## Use BTNC as Reset Button (active high)
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {btnC}];

## VGA Connector
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {VGA_R[0]}];
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {VGA_R[1]}];
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {VGA_R[2]}];
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports {VGA_R[3]}];
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[0]}];
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[1]}];
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[2]}];
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {VGA_B[3]}];
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {VGA_G[0]}];
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {VGA_G[1]}];
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {VGA_G[2]}];
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {VGA_G[3]}];
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports {VGA_HS_O}];
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports {VGA_VS_O}];

## LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
set_property PACKAGE_PIN V3 [get_ports {led[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
set_property PACKAGE_PIN W3 [get_ports {led[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
set_property PACKAGE_PIN U3 [get_ports {led[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
set_property PACKAGE_PIN P3 [get_ports {led[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
set_property PACKAGE_PIN N3 [get_ports {led[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
set_property PACKAGE_PIN P1 [get_ports {led[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
set_property PACKAGE_PIN L1 [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]


## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

#USB HID (PS/2)
set_property PACKAGE_PIN C17 [get_ports PS2Clk]                                         
set_property IOSTANDARD LVCMOS33 [get_ports PS2Clk]
set_property PULLUP true [get_ports PS2Clk]
set_property PACKAGE_PIN B17 [get_ports PS2Data]                                        
set_property IOSTANDARD LVCMOS33 [get_ports PS2Data]    
set_property PULLUP true [get_ports PS2Data]

 
## Switches
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
set_property PACKAGE_PIN V2 [get_ports {sw[8]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
set_property PACKAGE_PIN T3 [get_ports {sw[9]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
set_property PACKAGE_PIN T2 [get_ports {sw[10]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
set_property PACKAGE_PIN R3 [get_ports {sw[11]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
set_property PACKAGE_PIN W2 [get_ports {sw[12]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
set_property PACKAGE_PIN U1 [get_ports {sw[13]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
set_property PACKAGE_PIN T1 [get_ports {sw[14]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2 [get_ports {sw[15]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]
 

##Buttons
set_property PACKAGE_PIN U18 [get_ports btnC]						
set_property IOSTANDARD LVCMOS33 [get_ports btnC]
set_property PACKAGE_PIN T18 [get_ports btnU]						
set_property IOSTANDARD LVCMOS33 [get_ports btnU]
set_property PACKAGE_PIN W19 [get_ports btnL]						
set_property IOSTANDARD LVCMOS33 [get_ports btnL]
set_property PACKAGE_PIN T17 [get_ports btnR]						
set_property IOSTANDARD LVCMOS33 [get_ports btnR]
set_property PACKAGE_PIN U17 [get_ports btnD]						
set_property IOSTANDARD LVCMOS33 [get_ports btnD]
 


##Pmod Header JA
set_property PACKAGE_PIN J1 [get_ports {ja1}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja1}]
set_property PACKAGE_PIN L2 [get_ports {ja2}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja2}]
set_property PACKAGE_PIN J2 [get_ports {ja3}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja3}]
set_property PACKAGE_PIN G2 [get_ports {ja4}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja4}]
set_property PACKAGE_PIN H1 [get_ports {ja5}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja5}]
set_property PACKAGE_PIN K2 [get_ports {ja6}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja6}]
set_property PACKAGE_PIN H2 [get_ports {ja7}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja7}]
set_property PACKAGE_PIN G3 [get_ports {ja8}]					
set_property IOSTANDARD LVCMOS33 [get_ports {ja8}]

##Pmod Header JB
set_property PACKAGE_PIN A14 [get_ports {jb1}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb1}]
set_property PACKAGE_PIN A16 [get_ports {jb2}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb2}]
set_property PACKAGE_PIN B15 [get_ports {jb3}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb3}]
set_property PACKAGE_PIN B16 [get_ports {jb4}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb4}]
set_property PACKAGE_PIN A15 [get_ports {jb5}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb5}]
set_property PACKAGE_PIN A17 [get_ports {jb6}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb6}]
set_property PACKAGE_PIN C15 [get_ports {jb7}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb7}]
set_property PACKAGE_PIN C16 [get_ports {jb8}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jb8}]

##Pmod Header JC
set_property PACKAGE_PIN K17 [get_ports {jc1}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc1}]
set_property PACKAGE_PIN M18 [get_ports {jc2}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc2}]
set_property PACKAGE_PIN N17 [get_ports {jc3}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc3}]
set_property PACKAGE_PIN P18 [get_ports {jc4}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc4}]
set_property PACKAGE_PIN L17 [get_ports {jc5}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc5}]
set_property PACKAGE_PIN M19 [get_ports {jc6}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc6}]
set_property PACKAGE_PIN P17 [get_ports {jc7}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc7}]
set_property PACKAGE_PIN R18 [get_ports {jc8}]					
set_property IOSTANDARD LVCMOS33 [get_ports {jc8}]

##Pmod Header JXADC
set_property PACKAGE_PIN J3 [get_ports {jxa1}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa1}]
set_property PACKAGE_PIN L3 [get_ports {jxa2}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa2}]
set_property PACKAGE_PIN M2 [get_ports {jxa3}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa3}]
set_property PACKAGE_PIN N2 [get_ports {jxa4}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa4}]
set_property PACKAGE_PIN K3 [get_ports {jxa5}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa5}]
set_property PACKAGE_PIN M3 [get_ports {jxa6}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa6}]
set_property PACKAGE_PIN M1 [get_ports {jxa7}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa7}]
set_property PACKAGE_PIN N1 [get_ports {jxa8}]				
set_property IOSTANDARD LVCMOS33 [get_ports {jxa8}]

