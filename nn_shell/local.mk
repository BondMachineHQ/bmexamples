WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_BASM=program.basm
BOARD=alveou50
BASM_ARGS=-d -disable-dynamical-matching -chooser-min-word-size -chooser-force-same-name
BASM_LIB=library
MAPFILE=alveou50_maps.json
SHOWARGS=-dot-detail 5
VERILOG_OPTIONS=-comment-verilog
PLATFORM=xilinx_u50_gen3x16_xdma_5_202210_1
#HDL_REGRESSION=bondmachine.sv
#BM_REGRESSION=bondmachine.json
include bmapi.mk
