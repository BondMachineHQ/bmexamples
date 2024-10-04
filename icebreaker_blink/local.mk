WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_BASM=blink.basm
BOARD=icebreaker
MAPFILE=icebreaker_maps.json
SHOWARGS=-dot-detail 5
include slow.mk
include ibleds.mk
