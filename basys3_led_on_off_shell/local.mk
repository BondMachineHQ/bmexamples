WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_BASM=test.basm
BOARD=basys3
BASM_ARGS=-d -disable-dynamical-matching -bo $(WORKING_DIR)/bondmachine.bcof -chooser-min-word-size -chooser-force-same-name
BASM_LIB=library
MAPFILE=basys3_maps.json
SHOWARGS=-dot-detail 5
VERILOG_OPTIONS=-comment-verilog -bcof-file $(WORKING_DIR)/bondmachine.bcof
include simulation.mk
#include slow.mk
include ps2.mk
include vga.mk
