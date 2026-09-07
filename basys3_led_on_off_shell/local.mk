WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_BASM=shell.basm
BOARD=basys3
BASM_ARGS=-d -disable-dynamical-matching -bo $(WORKING_DIR)/bondmachine.bcof -chooser-min-word-size -chooser-force-same-name
BASM_LIB=library
MAPFILE=basys3_maps.json
SHOWARGS=-dot-detail 5
VERILOG_OPTIONS=-comment-verilog -bcof-file $(WORKING_DIR)/bondmachine.bcof
DEVICE_ID=localhost:3121/xilinx_tcf/Digilent/210183A8A266A
BY_SERIAL=/dev/serial/by-id/usb-Digilent_Digilent_USB_Device_210183A8A266-if01-port0
CABLE=digilent
include ps2.mk
include vga.mk
