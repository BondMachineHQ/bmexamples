WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_BASM=program.basm
BMINFO=bminfo.json
BOARD=alveou50
SHOWARGS=-dot-detail 5
VERILOG_OPTIONS=-comment-verilog
HWOPTIMIZATIONS=onlydestregs,onlysrcregs
BASM_ARGS=-dump-requirements $(WORKING_DIR)/requirements.json $(BMRANGES) -disable-dynamical-matching -chooser-min-word-size -chooser-force-same-name
BMREQS=$(WORKING_DIR)/requirements.json
PLATFORM=xilinx_u50_gen3x16_xdma_5_202210_1
MAPFILE=alveou50_maps.json
#HDL_REGRESSION=bondmachine.sv
#BM_REGRESSION=bondmachine.json
include bmapi.mk
