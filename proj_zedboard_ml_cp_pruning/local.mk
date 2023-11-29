WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_NEURALBOND=banknote.json
NEURALBOND_LIBRARY=neurons
NEURALBOND_ARGS=-config-file neuralbondconfig.json -operating-mode fragment
BMINFO=bminfo.json
BOARD=zedboard
MAPFILE=zedboard_maps.json
SHOWARGS=-dot-detail 5
VERILOG_OPTIONS=-comment-verilog
BASM_ARGS=-dump-requirements $(WORKING_DIR)/requirements.json -disable-dynamical-matching -chooser-min-word-size -chooser-force-same-name
BMREQS=$(WORKING_DIR)/requirements.json
BENCHCORE=i0,p0o0
#HDL_REGRESSION=bondmachine.sv
#BM_REGRESSION=bondmachine.json
include bmapi.mk
include crosscompile.mk
include buildroot.mk
include simbatch.mk
