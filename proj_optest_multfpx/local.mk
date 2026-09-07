WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_BASM=test.basm
BOARD=basys3
MAPFILE=basys3_maps.json
SHOWARGS=-dot-detail 5
BASM_ARGS=-d
VERILOG_OPTIONS=-comment-verilog
#HDL_REGRESSION=bondmachine.sv
#BM_REGRESSION=bondmachine.json
include simulation.mk
