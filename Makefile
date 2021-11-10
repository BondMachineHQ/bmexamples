SHELL=/bin/bash
INFOC=\033[32m
WARNC=\033[33m
ERRC=\033[31m
PJPC=\033[31m
DEFC=\033[0m
SEND=\033[400C\033[11D
include local.mk

##### Cluster or single target selection

ifneq ($(CLUSTER), )
	MAINTARGET=cluster
else
	MAINTARGET=bondmachine
endif

##### Project name

PROJECT_NAME=$(shell basename `pwd`)
PJP=$(PJPC)"[Project: $(PROJECT_NAME)]"$(DEFC)" - "

##### Toolchain selection

ifeq ($(shell [[ $(BOARD) == "basys3" || $(BOARD) == "zedboard"  || $(BOARD) == "zc702"  || $(BOARD) == "kc705" ]] && echo true ),true)
	TOOLCHAIN=vivado
	PROJECT_TARGET=$(WORKING_DIR)/vivado_creation
	SYNTESIS_TARGET=$(WORKING_DIR)/vivado_syntesis
	IMPLEMENTATION_TARGET=$(WORKING_DIR)/vivado_implementation
	BITSTREAM_TARGET=$(WORKING_DIR)/vivado_bitstream
	PROGRAM_TARGET=$(WORKING_DIR)/vivado_program
endif

ifeq ($(shell [[ $(BOARD) == "max1000" || $(BOARD) == "de10nano" ]] && echo true ),true)
	TOOLCHAIN=quartus
	PROJECT_TARGET=
endif

ifeq ($(shell [[ $(BOARD) == "ice40lp1k" || $(BOARD) == "icefun" ]] && echo true ),true)
	TOOLCHAIN=icestorm
	PROJECT_TARGET=
endif


##### Source selection

ifneq ($(SOURCE_BASM), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=basm $(BASM_ARGS) -o $(WORKING_DIR)/bondmachine.json $(SOURCE_BASM)
	SOURCE=$(SOURCE_BASM)
endif


ifneq ($(SOURCE_MULTIASM), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=bondgo $(BONDGO_ARGS) -input-file $(SOURCE_MULTIASM) -save-bondmachine $(WORKING_DIR)/bondmachine.json -multi-abstract-assembly-input
	SOURCE=$(SOURCE_MULTIASM)
endif

ifneq ($(SOURCE_ASM), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=bondgo $(BONDGO_ARGS) -input-file $(SOURCE_ASM) -save-bondmachine $(WORKING_DIR)/bondmachine.json -abstract-assembly-input
	SOURCE=$(SOURCE_ASM)
endif

ifneq ($(SOURCE_GO), )
ifneq ($(MAINTARGET), cluster)
	SOURCE_COMMAND=bondgo $(BONDGO_ARGS) -input-file $(SOURCE_GO) -save-bondmachine $(WORKING_DIR)/bondmachine.json -mpm
else
	SOURCE_COMMAND=bondgo $(BONDGO_ARGS) -input-file $(SOURCE_GO) -mpm $(ETHERBOND_ARGS) $(UDPBOND_ARGS) $(BONDIRECT_ARGS)
endif
	SOURCE=$(SOURCE_GO)
endif

ifneq ($(SOURCE_EXPRESSION), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=symbond -expression `cat $(SOURCE_EXPRESSION)` -save-bondmachine $(WORKING_DIR)/bondmachine.json
	SOURCE=$(SOURCE_EXPRESSION)
endif

ifneq ($(SOURCE_BOOLEAN), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=boolbond $(BOOL_ARGS) -system-file $(SOURCE_BOOLEAN) -save-bondmachine $(WORKING_DIR)/bondmachine.json
	SOURCE=$(SOURCE_BOOLEAN)
endif

ifneq ($(SOURCE_JSON), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=cp $(SOURCE_JSON) $(WORKING_DIR)/bondmachine.json
	SOURCE=$(SOURCE_JSON)
endif


##### Arguments processing

ifneq ($(BOARD_SLOW), )
	SLOW_ARGS=-board-slow -board-slow-factor $(BOARD_SLOW_FACTOR)
else
	SLOW_ARGS=
endif

ifneq ($(BENCHCORE), )
	BENCHCORE_ARGS=-attach-benchmark-core $(BENCHCORE)
else
	BENCHCORE_ARGS=
endif

ifneq ($(SHOWARGS), )
	SHOW_ARGS=$(SHOWARGS)
else
	SHOW_ARGS=
endif

ifneq ($(BOOLEANARGS), )
	BOOL_ARGS=$(BOOLEANARGS)
else
	BOOL_ARGS=
endif

ifneq ($(ETHERBOND_MACFILE), )
        ETHERBOND_MACFILE_ARGS=-etherbond-macfile $(ETHERBOND_MACFILE)
else
        ETHERBOND_MACFILE_ARGS=
endif

ifneq ($(ETHERBOND_EXTERNAL), )
        ETHERBOND_EXTERNAL_ARGS=-etherbond-external $(ETHERBOND_EXTERNAL)
else
        ETHERBOND_EXTERNAL_ARGS=
endif

ifneq ($(USE_ETHERBOND), )
ifeq ($(MAINTARGET), cluster)
	ETHERBOND_ARGS=-use-etherbond
else
	ETHERBOND_ARGS=-use-etherbond $(ETHERBOND_EXTERNAL_ARGS) -cluster-spec $(CLUSTER_SPEC) -peer-id $(PEER_ID) -etherbond-mapfile $(ETHERBOND_MAPFILE) $(ETHERBOND_MACFILE_ARGS)
endif
else
	ETHERBOND_ARGS=
endif

ifneq ($(UDPBOND_IPFILE), )
        UDPBOND_IPFILE_ARGS=-udpbond-ipfile $(UDPBOND_IPFILE)
else
        UDPBOND_IPFILE_ARGS=
endif

ifneq ($(UDPBOND_NETCONFIG), )
        UDPBOND_NETCONFIG_ARGS=-udpbond-netconfig $(UDPBOND_NETCONFIG)
else
        UDPBOND_NETCONFIG_ARGS=
endif

ifneq ($(UDPBOND_EXTERNAL), )
        UDPBOND_EXTERNAL_ARGS=-udpbond-external $(UDPBOND_EXTERNAL)
else
        UDPBOND_EXTERNAL_ARGS=
endif

ifneq ($(USE_UDPBOND), )
	UDPBOND_ARGS=-use-udpbond $(UDPBOND_EXTERNAL_ARGS) -cluster-spec $(CLUSTER_SPEC) -peer-id $(PEER_ID) -udpbond-mapfile $(UDPBOND_MAPFILE) $(UDPBOND_IPFILE_ARGS) $(UDPBOND_NETCONFIG_ARGS)
else
	UDPBOND_ARGS=
endif

ifneq ($(USE_BMAPI), )
	BMAPI_ARGS=-use-bmapi -bmapi-flavor $(BMAPI_FLAVOR) -bmapi-language $(BMAPI_LANGUAGE) -bmapi-mapfile $(BMAPI_MAPFILE) -bmapi-outdir $(BMAPI_OUTDIR)
else
	BMAPI_ARGS=
endif

ifneq ($(BASYS3_7SEG), )
	BASYS3_7SEG_ARGS=-basys3-7segment -basys3-7segment-map $(BASYS3_7SEG_MAP)
else
	BASYS3_7SEG_ARGS=
endif

ifneq ($(PS2KBD), )
	PS2KBD_ARGS=-ps2-keyboard -ps2-keyboard-map $(PS2KBD_MAP)
else
	PS2KBD_ARGS=
endif

ifneq ($(VGATEXT), )
	VGATEXT_ARGS=-vgatext -vgatext-flavor $(VGATEXT_FLAVOR) -vgatext-fonts $(VGATEXT_FONTS) -vgatext-header $(VGATEXT_HEADER)
else
	VGATEXT_ARGS=
endif


ifneq ($(EXTRA_INCLUDES), )
	EXTRA_INCLUDES_ARGS=$(EXTRA_INCLUDES)        
else
	EXTRA_INCLUDES_ARGS=
endif

ifneq ($(UDPBOND_IPFILE), )
        UDPBOND_IPFILE_ARGS=
else
        UDPBOND_IPFILE_ARGS=
endif

ifneq ($(UDPBOND_NETCONFIG), )
        UDPBOND_NETCONFIG_ARGS=
else
        UDPBOND_NETCONFIG_ARGS=
endif

ifneq ($(USE_UDPBOND), )
	UDPBOND_ARGS=-use-udpbond $(UDPBOND_NETCONFIG_ARGS) $(UDPBOND_IPFILE_ARGS)
else
	UDPBOND_ARGS=
endif

ifneq ($(USE_BONDIRECT), )
	BONDIRECT_ARGS=-use-bondirect
else
	BONDIRECT_ARGS=
endif

##### Rottdir

ifeq ($(ROOTDIR), )
        ROOTDIR=..
endif

ifneq ($(HDL_REGRESSION), )
	HDL_REGRESSION_TARGETS=$(WORKING_DIR)/hdl_target
else
	HDL_REGRESSION_TARGETS=
endif

ifneq ($(BM_REGRESSION), )
	BM_REGRESSION_TARGETS=$(WORKING_DIR)/bondmachine_target
else
	BM_REGRESSION_TARGETS=
endif



##### Placeholders targets
 
all: ${MAINTARGET}

bondmachine: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) check-working-dir
hdl: $(WORKING_DIR)/hdl_target | $(WORKING_DIR) check-working-dir
project: $(PROJECT_TARGET) | $(WORKING_DIR) check-working-dir
syntesis: $(SYNTESIS_TARGET) | $(WORKING_DIR) check-working-dir
implementation: $(IMPLEMENTATION_TARGET | $(WORKING_DIR) check-working-dir
bitstream: $(BITSTREAM_TARGET) | $(WORKING_DIR) check-working-dir
bmapp: $(WORKING_DIR)/bmapp_target | $(WORKING_DIR) check-working-dir

.PHONY: program
program: $(PROGRAM_TARGET) | $(WORKING_DIR) check-working-dir


##### Toolchain independent targets

$(WORKING_DIR):
	@echo -e "$(PJP)$(INFOC)[Working directory creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	mkdir -p $(WORKING_DIR)
	@echo -e "$(PJP)$(INFOC)[Working directory creation end]$(DEFC)"
	@echo


$(WORKING_DIR)/bondmachine_target: $(SOURCE) | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[BondMachine generation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	$(SOURCE_COMMAND)
	@touch $(WORKING_DIR)/bondmachine_target
	@echo -e "$(PJP)$(INFOC)[BondMachine generation end]$(DEFC)"
	@echo

$(WORKING_DIR)/hdl_target:  $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[HDL generation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -create-verilog -verilog-mapfile $(MAPFILE) -verilog-flavor $(BOARD) $(BENCHCORE_ARGS) $(SLOW_ARGS) $(BASYS3_7SEG_ARGS) $(PS2KBD_ARGS) $(VGATEXT_ARGS) $(ETHERBOND_ARGS) $(UDPBOND_ARGS) $(BMAPI_ARGS) $(VERILOG_OPTIONS)
	echo > $(WORKING_DIR)/bondmachine.sv
	for i in `ls *.v | sort -d` ; do cat $$i >> $(WORKING_DIR)/bondmachine.sv ; done
	rm -f *.v
	echo > $(WORKING_DIR)/bondmachine.vhd
	for i in `ls *.vhd | sort -d` ; do cat $$i >> $(WORKING_DIR)/bondmachine.vhd ; done
	rm -f *.vhd
	@touch $(WORKING_DIR)/hdl_target
	@echo -e "$(PJP)$(INFOC)[HDL generation end]$(DEFC)"
	@echo

$(WORKING_DIR)/bmapp_target: $(WORKING_DIR)/hdl_target | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[BondMachine App compiling begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	rm -rf $(WORKING_DIR)/app
	mkdir -p $(WORKING_DIR)/app
	cp $(BMAPI_GOAPP) $(WORKING_DIR)/app
	cd $(WORKING_DIR)/app ; go mod init $(BMAPI_GOMOD) ; go mod edit -replace git.fisica.unipg.it/bondmachine/bmapiusbuart.git=../bmapi
	cd $(WORKING_DIR)/app ; go build
	@touch $(WORKING_DIR)/bmapp_target
	@echo -e "$(PJP)$(INFOC)[BondMachine App compiling end]$(DEFC)"
	@echo

bmapprun: $(WORKING_DIR)/bmapp_target program | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[BondMachine run App begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cd $(WORKING_DIR)/app ; go run $(BMAPI_GOAPP)
	@echo -e "$(PJP)$(INFOC)[BondMachine run App end]$(DEFC)"
	@echo


show: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[BondMachine diagram show begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -emit-dot $(SHOW_ARGS) | dot -Txlib
	@echo -e "$(PJP)$(INFOC)[BondMachine diagram show end]$(DEFC)"
	@echo

simulate: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) check-working-dir
ifndef SIMBOX_FILE
	$(error SIMBOX_FILE is undefined)
endif
ifndef SIM_INTERACTIONS
	$(error SIM_INTERACTIONS is undefined)
endif
	@echo -e "$(PJP)$(INFOC)[BondMachine simulation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cp $(SIMBOX_FILE) $(WORKING_DIR)
	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -sim -simbox-file $(WORKING_DIR)/$(SIMBOX_FILE) -sim-interactions $(SIM_INTERACTIONS) $(SIM_OPTIONS)
	@echo -e "$(PJP)$(INFOC)[BondMachine simulation end]$(DEFC)"
	@echo

simvideo: simulate
	@echo -e "$(PJP)$(INFOC)[Simulation video creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	rm -f graphviz.mp4
	./Makevideo
	mplayer -fs graphviz.mp4
	@echo -e "$(PJP)$(INFOC)[Simulation video creation end]$(DEFC)"
	@echo

.PHONY: regressionhdl
regressionhdl: $(HDL_REGRESSION_TARGETS) | silent
ifneq ($(HDL_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[HDL Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(HDL_REGRESSION); do echo -n "$$rfile" ; ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -e "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || (echo -e "$(ERRC)$(SEND)[ Failed ]$(DEFC)") ; done
	@echo -e "$(PJP)$(INFOC)[HDL Regression end]$(DEFC)"
	@echo
endif

.PHONY: regressionbm
regressionbm: $(BM_REGRESSION_TARGETS) | silent
ifneq ($(BM_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(BM_REGRESSION); do echo -n "$$rfile" ; ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -e "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || (echo -ne "$(ERRC)$(SEND)[ Failed ]$(DEFC)") ; done
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression end]$(DEFC)"
	@echo
endif

.PHONY: regression
regression: regressionbm regressionhdl

.PHONY: regressionhdldiff
regressionhdldiff: $(HDL_REGRESSION_TARGETS)
ifneq ($(HDL_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[HDL Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(HDL_REGRESSION); do ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -ne "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || ( vimdiff $(WORKING_DIR)/$$rfile $$rfile.reg ) ; done
	@echo -e "$(PJP)$(INFOC)[HDL Regression end]$(DEFC)"
	@echo
endif

.PHONY: regressionbmdiff
regressionbmdiff: $(BM_REGRESSION_TARGETS)
ifneq ($(BM_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(BM_REGRESSION); do ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -ne "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || ( vimdiff $(WORKING_DIR)/$$rfile $$rfile.reg ) ; done
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression end]$(DEFC)"
	@echo
endif

.PHONY: regressiondiff
regressiondiff: regressionbmdiff regressionhdldiff

.PHONY: regressionhdlreset
regressionhdlreset: $(HDL_REGRESSION_TARGETS)
ifneq ($(HDL_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[HDL Regression reset begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(HDL_REGRESSION); do cp $(WORKING_DIR)/$$rfile $$rfile.reg ; echo "$$rfile Resetted" ; done
	@echo -e "$(PJP)$(INFOC)[HDL Regression reset end]$(DEFC)"
	@echo
endif

.PHONY: regressionbmreset
regressionbmreset: $(BM_REGRESSION_TARGETS)
ifneq ($(BM_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression reset begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(BM_REGRESSION); do cp $(WORKING_DIR)/$$rfile $$rfile.reg ; echo "$$rfile Resetted" ; done
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression reset end]$(DEFC)"
	@echo
endif

.PHONY: regressionreset
regressionreset: regressionbmreset regressionhdlreset


##### Iverilog gtkwave toolchain

# TODO Convert here to a new toolchain for iverilog
#$(WORKING_DIR)/bondmachine_simulation.sv:  $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) check-working-dir
#	cp $(SIMBOX_FILE) $(WORKING_DIR)
#	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -create-verilog -verilog-mapfile $(MAPFILE) -verilog-flavor iverilog $(BENCHCORE_ARGS) $(VERILOG_OPTIONS) -verilog-simulation -simbox-file $(WORKING_DIR)/$(SIMBOX_FILE) -sim-interactions $(SIM_INTERACTIONS)
#	echo > $(WORKING_DIR)/bondmachine_simulation.sv
#	for i in `ls *.v | sort -d` ; do cat $$i >> $(WORKING_DIR)/bondmachine_simulation.sv ; done
#	rm -f *.v


# TODO Convert here to a new toolchain for iverilog gtkwave
#simverilog: $(WORKING_DIR)/bondmachine_simulation.sv | $(WORKING_DIR) check-working-dir
#	iverilog $(WORKING_DIR)/bondmachine_simulation.sv -o $(WORKING_DIR)/bondmachine_simulation.vvp
#	vvp $(WORKING_DIR)/bondmachine_simulation.vvp 
#
#simgtkwave: $(WORKING_DIR)/bondmachine_simulation.sv | $(WORKING_DIR) check-working-dir
#	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -show-program-alias
#	mv p*.alias $(WORKING_DIR)
#	iverilog $(WORKING_DIR)/bondmachine_simulation.sv -o $(WORKING_DIR)/bondmachine_simulation.vvp
#	vvp $(WORKING_DIR)/bondmachine_simulation.vvp 
#	gtkwave $(WORKING_DIR)/bondmachine.vcd


##### Vivado toolchain targets

$(WORKING_DIR)/$(BOARD).xdc: | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - copy constraints begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cp $(BOARD).xdc $(WORKING_DIR)
	@touch $(WORKING_DIR)/contraint_target
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - copy constraints end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_creation:  $(WORKING_DIR)/$(BOARD).xdc $(WORKING_DIR)/hdl_target | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - project creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo  "set origin_dir \"$(CURRENT_DIR)/$(WORKING_DIR)\"" > $(WORKING_DIR)/vivado-script-creation.tcl
	cat $(ROOTDIR)/$(BOARD)_template_creation.tcl >> $(WORKING_DIR)/vivado-script-creation.tcl
	rm -rf $(WORKING_DIR)/bondmachine
	rm -rf $(WORKING_DIR)/vivado.*
	bash -c "cd $(WORKING_DIR) ; start_vivado.sh vivado-script-creation.tcl"
	@touch $(WORKING_DIR)/vivado_creation
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - project creation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_syntesis: $(WORKING_DIR)/vivado_creation | $(WORKING_DIR)  check-working-dir
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - syntesis begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo "open_project \"$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.xpr\"" > $(WORKING_DIR)/vivado-script-syntesis.tcl
	cat $(ROOTDIR)/$(BOARD)_template_syntesis.tcl >> $(WORKING_DIR)/vivado-script-syntesis.tcl
	bash -c "cd $(WORKING_DIR) ; start_vivado.sh vivado-script-syntesis.tcl"
	@touch $(WORKING_DIR)/vivado_syntesis
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - syntesis end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_implementation: $(WORKING_DIR)/vivado_syntesis | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - implementation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo "open_project \"$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.xpr\"" > $(WORKING_DIR)/vivado-script-implementation.tcl
	cat $(ROOTDIR)/$(BOARD)_template_implementation.tcl >> $(WORKING_DIR)/vivado-script-implementation.tcl
	bash -c "cd $(WORKING_DIR) ; start_vivado.sh vivado-script-implementation.tcl"
	@touch $(WORKING_DIR)/vivado_implementation
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - implementation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_bitstream: $(WORKING_DIR)/vivado_implementation | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - write bitstream begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo "open_project \"$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.xpr\"" > $(WORKING_DIR)/vivado-script-bitstream.tcl
	cat $(ROOTDIR)/$(BOARD)_template_bitstream.tcl >> $(WORKING_DIR)/vivado-script-bitstream.tcl
	bash -c "cd $(WORKING_DIR) ; start_vivado.sh vivado-script-bitstream.tcl"
	@touch $(WORKING_DIR)/vivado_bitstream
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - write bitstream end]$(DEFC)"
	@echo

.PHONY: $(WORKING_DIR)/vivado_program
$(WORKING_DIR)/vivado_program: $(WORKING_DIR)/vivado_bitstream | $(WORKING_DIR) check-working-dir
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - programming begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo "open_project \"$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.xpr\"" > $(WORKING_DIR)/vivado-script-program.tcl
	cat $(ROOTDIR)/$(BOARD)_template_program_1.tcl >> $(WORKING_DIR)/vivado-script-program.tcl
ifeq ($(BOARD),zedboard)
		echo "set_property PROGRAM.FILE {$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.runs/impl_1/bondmachine_main.bit} [lindex [get_hw_devices xc7z020_1] 0]" >> $(WORKING_DIR)/vivado-script-program.tcl
endif
ifeq ($(BOARD),basys3)
		echo "set_property PROGRAM.FILE {$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.runs/impl_1/bondmachine_main.bit} [lindex [get_hw_devices] 0]" >> $(WORKING_DIR)/vivado-script-program.tcl
endif
	cat $(ROOTDIR)/$(BOARD)_template_program_2.tcl >> $(WORKING_DIR)/vivado-script-program.tcl
	bash -c "cd $(WORKING_DIR) ; start_vivado.sh vivado-script-program.tcl"
	@touch $(WORKING_DIR)/vivado_program
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - programming end]$(DEFC)"
	@echo


#### Checks and cleanups

.PHONY: clean
clean:
	@echo -e "$(PJP)$(INFOC)[Cleanup begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	rm -rf $(WORKING_DIR)
	rm -f vivado*
	rm -f graphviz*
	rm -rf ebcluster*
	rm -f a.out*
	@echo -e "$(PJP)$(INFOC)[Cleanup end]$(DEFC)"
	@echo
 
.PHONY: check-working-dir
check-working-dir:
ifndef WORKING_DIR
	$(error WORKING_DIR is undefined)
endif


silent:
	@:

#### Clustering

.PHONY: cluster
cluster: $(SOURCE)
	$(SOURCE_COMMAND)





######3 OLD Cluster makefile

# 
# 
 

# .PHONY: all
# all: clean dirsudpbond
# 

# .PHONY: dirsetherbond
# dirsetherbond: bondmachines
# 	for i in `ls ebcluster*bm.json` ; do mkdir `basename $$i _bm.json` ; cp -a `basename $$i _bm.json`_* `basename $$i _bm.json` ; cp ebcluster.json `basename $$i _bm.json` ; ln -s ../../Makefile `basename $$i _bm.json`/Makefile ; done
# 	for i in `ls ebcluster*bm.json` ; do mkdir `basename $$i _bm.json`/working_dir ; done
# 	for i in `ls ebcluster*bm.json` ; do cp basys3.xdc `basename $$i _bm.json`/ ; done
# 	for i in `ls ebcluster*bm.json` ; do echo 'WORKING_DIR=working_dir' > `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo 'CURRENT_DIR=$$(shell pwd)' >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "SOURCE_JSON=$$i" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "BOARD=$(BOARD)" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do PEER=`echo $$i | sed 's/\_bm\.json//' | sed 's/ebcluster\_//'` ; cat $(MAPFILE) | json $$PEER > `basename $$i _bm.json`/`basename $$i _bm.json`_residual.json ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "MAPFILE=`basename $$i _bm.json`_residual.json" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "ROOTDIR=../.." >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "USE_ETHERBOND=yes" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "CLUSTER_SPEC=ebcluster.json" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do PEER=`echo $$i | sed 's/\_bm\.json//' | sed 's/ebcluster\_peer\_//'` ;  echo "PEER_ID=$$PEER" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "ETHERBOND_MAPFILE=`basename $$i _bm.json`_io.json" >> `basename $$i _bm.json`/local.mk ; done
# 	rm -f ebcluster*.json
# 
# show: all
# 	redeployer -redeployer-file  redeployer.json -emit-dot  -dot-detail 5 | dot -Txlib
# 
# .PHONY: dirsudpbond
# dirsudpbond: bondmachines
# 	for i in `ls ebcluster*bm.json` ; do mkdir `basename $$i _bm.json` ; cp -a `basename $$i _bm.json`_* `basename $$i _bm.json` ; cp ebcluster.json `basename $$i _bm.json` ; ln -s ../../Makefile `basename $$i _bm.json`/Makefile ; done
# 	for i in `ls ebcluster*bm.json` ; do mkdir `basename $$i _bm.json`/working_dir ; done
# 	for i in `ls ebcluster*bm.json` ; do cp basys3.xdc `basename $$i _bm.json`/ ; done
# 	for i in `ls ebcluster*bm.json` ; do cp $(UDPBOND_NETCONFIG) `basename $$i _bm.json`/ ; done
# 	for i in `ls ebcluster*bm.json` ; do cp $(UDPBOND_IPFILE) `basename $$i _bm.json`/ ; done
# 	for i in `ls ebcluster*bm.json` ; do echo 'WORKING_DIR=working_dir' > `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo 'CURRENT_DIR=$$(shell pwd)' >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "SOURCE_JSON=$$i" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "BOARD=$(BOARD)" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do PEER=`echo $$i | sed 's/\_bm\.json//' | sed 's/ebcluster\_//'` ; cat $(MAPFILE) | json $$PEER > `basename $$i _bm.json`/`basename $$i _bm.json`_residual.json ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "MAPFILE=`basename $$i _bm.json`_residual.json" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "ROOTDIR=../.." >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "USE_UDPBOND=yes" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "CLUSTER_SPEC=ebcluster.json" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do PEER=`echo $$i | sed 's/\_bm\.json//' | sed 's/ebcluster\_peer\_//'` ;  echo "PEER_ID=$$PEER" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "UDPBOND_MAPFILE=`basename $$i _bm.json`_io.json" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "UDPBOND_NETCONFIG=$(UDPBOND_NETCONFIG)" >> `basename $$i _bm.json`/local.mk ; done
# 	for i in `ls ebcluster*bm.json` ; do echo "UDPBOND_IPFILE=$(UDPBOND_IPFILE)" >> `basename $$i _bm.json`/local.mk ; done
# 	if [ "a$(EXTRA_INCLUDES_ARGS)" != "a" ] ; then for extra in "$(EXTRA_INCLUDES_ARGS)" ; do for i in `ls ebcluster*bm.json` ; do cp $$extra `basename $$i _bm.json`/ ; done ; done ; fi
# 	if [ "a$(EXTRA_INCLUDES_ARGS)" != "a" ] ; then for extra in "$(EXTRA_INCLUDES_ARGS)" ; do for i in `ls ebcluster*bm.json` ; do  echo "include $$extra" >> `basename $$i _bm.json`/local.mk ; done ; done ; fi
# 	rm -f ebcluster*.json
