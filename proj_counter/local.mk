WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_GO=counter.go
BOARD=basys3
MAPFILE=basys3_maps.json
SHOWARGS=-dot-detail 5
include slow.mk
