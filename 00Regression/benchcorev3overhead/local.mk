WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
BOARD=zedboard
SOURCE_BASM=test.basm
BASM_ARGS=-disable-dynamical-matching -chooser-min-word-size -chooser-force-same-name
MAPFILE=zedboard_maps.json
SHOWARGS=-dot-detail 5
EXTRACLEAN=sicv2 num_outputs.txt bondmachine.png statistics.json source.mk out.basm
include bmapi.mk
include deploy.mk
include simbatch.mk
include simulation.mk
