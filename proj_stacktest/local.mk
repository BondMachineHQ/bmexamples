WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
#SOURCE_JSON=stacktest.json
SOURCE_BASM=stacktest.basm
BASM_ARGS=-d
BOARD=basys3
MAPFILE=basys3_maps.json
SHOWARGS=-dot-detail 5
VERILOG_OPTIONS=-comment-verilog
include slow.mk
