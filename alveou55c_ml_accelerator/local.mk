WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_NEURALBOND=banknote.json
NEURALBOND_LIBRARY=neurons
NEURALBOND_ARGS=-config-file neuralbondconfig.json -operating-mode fragment -io-mode sync -data-type float32 -register-size 32
BMINFO=bminfo.json
BOARD=alveou55c
MAPFILE=alveou55c_maps.json
SHOWARGS=-dot-detail 5
SHOWRENDERER=dot -Txlib
VERILOG_OPTIONS=-comment-verilog 
#BENCHCORE=i0,p10o0
HWOPTIMIZATIONS=onlydestregs,onlysrcregs
BASM_ARGS=-dump-requirements $(WORKING_DIR)/requirements.json $(BMRANGES) -disable-dynamical-matching -chooser-min-word-size -chooser-force-same-name
BMREQS=$(WORKING_DIR)/requirements.json
PLATFORM=xilinx_u55c_gen3x16_xdma_3_202210_1
#HDL_REGRESSION=bondmachine.sv
#BM_REGRESSION=bondmachine.json
include bmapi.mk
include simbatch.mk
