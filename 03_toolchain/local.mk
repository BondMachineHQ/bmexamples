WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_ASM=counter.asm
BOARD=zedboard
BONDGO_ARGS=-d
SHOWARGS=-dot-detail 5
MAPFILE=maps.json
include slow.mk
