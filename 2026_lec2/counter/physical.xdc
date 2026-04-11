set_property PACKAGE_PIN AB25 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

set_property PACKAGE_PIN AE10 [get_ports clk]
set_property IOSTANDARD SSTL135_DCI [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property PACKAGE_PIN R24 [get_ports led]

set_property INTERNAL_VREF 0.675 [get_iobanks 33]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]
