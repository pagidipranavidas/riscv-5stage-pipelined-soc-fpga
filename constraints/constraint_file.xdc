### ============================================================
### constraint_uart.xdc  -  Basys3 (xc7a35tcpg236-1)
### Top module: top_uart
### ============================================================

### 100 MHz Clock  (W5)
#set_property PACKAGE_PIN W5 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
#create_clock -period 10.000 -name sys_clk [get_ports clk]

### Reset - Centre Button (U18)  active HIGH
#set_property PACKAGE_PIN U18 [get_ports rst]
#set_property IOSTANDARD LVCMOS33 [get_ports rst]

### UART TX - USB-UART bridge on Basys3 (A18)
### Connect PuTTY: 9600 baud, 8 data bits, No parity, 1 stop bit
#set_property PACKAGE_PIN A18 [get_ports uart_txd]
#set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]


## ============================================================
## Basys3 Constraints File for top_uart.v
## Board: Digilent Basys3 (Artix-7 xc7a35tcpg236-1)
## ============================================================

## ---- 100 MHz System Clock (W5) ----
set_property PACKAGE_PIN W5      [get_ports clk]
set_property IOSTANDARD  LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ---- Reset: Centre Button btnC (T17) - Active HIGH ----
set_property PACKAGE_PIN T17     [get_ports rst]
set_property IOSTANDARD  LVCMOS33 [get_ports rst]

## ---- UART TX: USB-UART Bridge (A18) ----
## This pin connects to the FT2232HQ USB-UART chip on Basys3
## Connect PuTTY to the COM port that appears when you plug in USB
## Settings: 9600 baud, 8 data bits, No parity, 1 stop bit (8N1)
set_property PACKAGE_PIN A18     [get_ports uart_txd]
set_property IOSTANDARD  LVCMOS33 [get_ports uart_txd]

## ============================================================
## Optional: Onboard LEDs for debug (connect to ALUResult bits)
## Uncomment if you want to also see ALU result on LEDs
## ============================================================
## LED 0..15 = ALUResult[15:0]
#set_property PACKAGE_PIN U16 [get_ports {led[0]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[0]}]
#set_property PACKAGE_PIN E19 [get_ports {led[1]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[1]}]
#set_property PACKAGE_PIN U19 [get_ports {led[2]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[2]}]
#set_property PACKAGE_PIN V19 [get_ports {led[3]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[3]}]
#set_property PACKAGE_PIN W18 [get_ports {led[4]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[4]}]
#set_property PACKAGE_PIN U15 [get_ports {led[5]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[5]}]
#set_property PACKAGE_PIN U14 [get_ports {led[6]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[6]}]
#set_property PACKAGE_PIN V14 [get_ports {led[7]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[7]}]
#set_property PACKAGE_PIN V13 [get_ports {led[8]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[8]}]
#set_property PACKAGE_PIN V3  [get_ports {led[9]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[9]}]
#set_property PACKAGE_PIN W3  [get_ports {led[10]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[10]}]
#set_property PACKAGE_PIN U3  [get_ports {led[11]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[11]}]
#set_property PACKAGE_PIN P3  [get_ports {led[12]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[12]}]
#set_property PACKAGE_PIN N3  [get_ports {led[13]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[13]}]
#set_property PACKAGE_PIN P1  [get_ports {led[14]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[14]}]
#set_property PACKAGE_PIN L1  [get_ports {led[15]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {led[15]}]
