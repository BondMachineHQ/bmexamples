WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_GO=chain.go
BOARD=zedboard
MAPFILE=maps.json
BONDGO_ARGS=-d
SHOWARGS=-dot-detail 5
include slow.mk
