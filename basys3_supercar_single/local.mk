WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
BOARD=basys3
SHOWARGS=-dot-detail 5
BASM_ARGS=-d -disable-dynamical-matching -bo $(WORKING_DIR)/bondmachine.bcof -chooser-min-word-size -chooser-force-same-name -create-mapfile basys3_maps.json
BASM_LIB=library
VERILOG_OPTIONS=-comment-verilog
