WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_BOOLEAN=expression.txt
BOARD=basys3
MAPFILE=basys3_maps.json
SHOWARGS=-dot-detail 5
BOOLEANARGS=-io-model async
include simulation.mk
