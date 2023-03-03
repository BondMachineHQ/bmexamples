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

ifeq ($(shell [[ $(BOARD) == "basys3" || $(BOARD) == "zedboard"  || $(BOARD) == "zc702"  || $(BOARD) == "kc705" || $(BOARD) == "ebaz4205" ]] && echo true ),true)
	BOARDOK=yes
	TOOLCHAIN=vivado
	VIVADO_VERSION=$(shell vivado -version | head -n 1 | sed -e 's/.*\([0-9][0-9][0-9][0-9]\.[0-9]\).*/\1/')
	PROJECT_TARGET=$(WORKING_DIR)/vivado_creation
	SYNTHESIS_TARGET=$(WORKING_DIR)/vivado_synthesis
	IMPLEMENTATION_TARGET=$(WORKING_DIR)/vivado_implementation
	BITSTREAM_TARGET=$(WORKING_DIR)/vivado_bitstream
	PROGRAM_TARGET=$(WORKING_DIR)/vivado_program
	ACCELERATOR_TARGET=$(WORKING_DIR)/vivado_accelerator
	DESIGN_TARGET=$(WORKING_DIR)/vivado_design_creation
	DESIGN_SYNTHESIS_TARGET=$(WORKING_DIR)/vivado_design_synthesis
	DESIGN_IMPLEMENTATION_TARGET=$(WORKING_DIR)/vivado_design_implementation
	DESIGN_BISTREAM_TARGET=$(WORKING_DIR)/vivado_design_bitstream
	EXPORT_HARDWARD_TARGET=$(WORKING_DIR)/vivado_export_hardware
	DEVICETREE_TARGET=$(WORKING_DIR)/vivado_devicetree
	KERNEL_MODULE_TARGET=$(WORKING_DIR)/vivado_kernel_module
	BUILDROOT_TARGET=$(WORKING_DIR)/vivado_buildroot
endif

ifeq ($(shell [[ $(BOARD) == "max1000" || $(BOARD) == "de10nano" ]] && echo true ),true)
	BOARDOK=yes
	TOOLCHAIN=quartus
	PROJECT_TARGET=$(WORKING_DIR)/quartus_creation
	SYNTHESIS_TARGET=$(WORKING_DIR)/quartus_synthesis
	IMPLEMENTATION_TARGET=$(WORKING_DIR)/quartus_implementation
	BITSTREAM_TARGET=$(WORKING_DIR)/quartus_bitstream
	PROGRAM_TARGET=$(WORKING_DIR)/quartus_program
endif

ifeq ($(shell [[ $(BOARD) == "ice40lp1k" || $(BOARD) == "icefun" || $(BOARD) == "icebreaker" || $(BOARD) == "icesugarnano" ]] && echo true ),true)
	BOARDOK=yes
	TOOLCHAIN=icestorm
	PROJECT_TARGET=$(WORKING_DIR)/icestorm_creation
	SYNTHESIS_TARGET=$(WORKING_DIR)/icestorm_synthesis
	IMPLEMENTATION_TARGET=$(WORKING_DIR)/icestorm_implementation
	BITSTREAM_TARGET=$(WORKING_DIR)/icestorm_bitstream
	PROGRAM_TARGET=$(WORKING_DIR)/icestorm_program
endif

ifeq ($(shell [[ $(BOARD) == "icefun" ]] && echo true ),true)
	BOARD_MODEL="hx8k"
	BOARD_PACKAGE="cb132"
endif

ifeq ($(shell [[ $(BOARD) == "ice40lp1k" ]] && echo true ),true)
	BOARD_MODEL="lp1k"
	BOARD_PACKAGE="qn84"
endif

ifeq ($(shell [[ $(BOARD) == "icebreaker" ]] && echo true ),true)
	BOARD_MODEL="up5k"
	BOARD_PACKAGE="sg48"
endif

##### Source selection

ifneq ($(SOURCE_BASM), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=basm $(BASM_ARGS) $(BMINFO_ARGS) -o $(WORKING_DIR)/bondmachine.json $(SOURCE_BASM)
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

ifneq ($(SOURCE_MATRIXWORK), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=matrixwork -constants $(SOURCE_MATRIXWORK) -constant-matrix $(MATRIXWORKMATRIX) -numerical-type $(MATRIXWORKTYPE) -save-bondmachine $(WORKING_DIR)/bondmachine.json
	SOURCE=$(SOURCE_MATRIXWORK)
endif

ifneq ($(SOURCE_NEURALBOND), )
ifeq ($(MAINTARGET), cluster)
$(error Unsupported)
endif
	SOURCE_COMMAND=neuralbond -net-file $(SOURCE_NEURALBOND) -neuron-lib-path $(NEURALBOND_LIBRARY) -save-basm $(WORKING_DIR)/bondmachine.basm $(NEURALBOND_ARGS) $(BMINFO_ARGS) ; basm $(BASM_ARGS) $(BMINFO_ARGS) -o $(WORKING_DIR)/bondmachine.json $(WORKING_DIR)/bondmachine.basm $(NEURALBOND_LIBRARY)/*.basm
	SOURCE=$(SOURCE_NEURALBOND)
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

ifneq ($(SHOWRENDERER), )
	SHOW_RENDERER=$(SHOWRENDERER)
else
	SHOW_RENDERER=dot -Txlib
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
ifeq ($(BMAPI_FLAVOR),aximm)
	BMAPI_ARGS=-use-bmapi -bmapi-flavor $(BMAPI_FLAVOR) -bmapi-language $(BMAPI_LANGUAGE) -bmapi-mapfile $(BMAPI_MAPFILE) -bmapi-liboutdir $(BMAPI_LIBOUTDIR) -bmapi-modoutdir $(BMAPI_MODOUTDIR) -bmapi-auxoutdir $(BMAPI_AUXOUTDIR)
endif
ifeq ($(BMAPI_FLAVOR),axist)
	BMAPI_ARGS=-use-bmapi -bmapi-flavor $(BMAPI_FLAVOR) -bmapi-language $(BMAPI_LANGUAGE) -bmapi-mapfile $(BMAPI_MAPFILE) -bmapi-framework $(BMAPI_FRAMEWORK) -bmapi-flavor-version $(BMAPI_FLAVOR_VERSION) -bmapi-auxoutdir $(BMAPI_AUXOUTDIR)
endif
ifeq ($(BMAPI_FLAVOR),uartusb)
	BMAPI_ARGS=-use-bmapi -bmapi-flavor $(BMAPI_FLAVOR) -bmapi-language $(BMAPI_LANGUAGE) -bmapi-mapfile $(BMAPI_MAPFILE) -bmapi-liboutdir $(BMAPI_LIBOUTDIR)
endif
else
	BMAPI_ARGS=
endif

ifneq ($(BASYS3_7SEG), )
	BASYS3_7SEG_ARGS=-basys3-7segment -basys3-7segment-map $(BASYS3_7SEG_MAP)
else
	BASYS3_7SEG_ARGS=
endif

ifneq ($(IB_LEDS), )
	IB_LEDS_ARGS=-icebreaker-leds -icebreaker-leds-map $(IB_LEDS_MAP)
else
	IB_LEDS_ARGS=
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

##### Rootdir

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

ifneq ($(SIM_REGRESSION), )
	SIM_REGRESSION_TARGETS=simulate
else
	SIM_REGRESSION_TARGETS=
endif

ifneq ($(BMINFO), )
        BMINFO_ARGS=-bminfo-file $(BMINFO)
else
        BMINFO_ARGS=
endif



##### Placeholders targets
 
all: ${MAINTARGET}

bondmachine: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
hdl: $(WORKING_DIR)/hdl_target | $(WORKING_DIR) checkenv
project: $(PROJECT_TARGET) | $(WORKING_DIR) checkenv
synthesis: $(SYNTHESIS_TARGET) | $(WORKING_DIR) checkenv
implementation: $(IMPLEMENTATION_TARGET) | $(WORKING_DIR) checkenv
bitstream: $(BITSTREAM_TARGET) | $(WORKING_DIR) checkenv
design: $(DESIGN_TARGET) | $(WORKING_DIR) checkenv
accelerator: $(ACCELERATOR_TARGET) | $(WORKING_DIR) checkenv
design_synthesis: $(DESIGN_SYNTHESIS_TARGET) | $(WORKING_DIR) checkenv
design_implementation: $(DESIGN_IMPLEMENTATION_TARGET) | $(WORKING_DIR) checkenv
design_bitstream: $(DESIGN_BISTREAM_TARGET) | $(WORKING_DIR) checkenv
export_hardware: $(EXPORT_HARDWARD_TARGET) | $(WORKING_DIR) checkenv
devicetree: $(DEVICETREE_TARGET) | $(WORKING_DIR) checkenv
kernel_module: $(KERNEL_MODULE_TARGET) | $(WORKING_DIR) checkenv
buildroot: $(BUILDROOT_TARGET) | $(WORKING_DIR) checkenv
bmapp: $(WORKING_DIR)/bmapp_target | $(WORKING_DIR) checkenv

.PHONY: program
program: $(PROGRAM_TARGET) | $(WORKING_DIR) checkenv


##### Toolchain independent targets

name:
	@echo $(PROJECT_NAME)

$(WORKING_DIR):
	@echo -e "$(PJP)$(INFOC)[Working directory creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	mkdir -p $(WORKING_DIR)
	@echo -e "$(PJP)$(INFOC)[Working directory creation end]$(DEFC)"
	@echo


$(WORKING_DIR)/bondmachine_target: $(SOURCE) | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[BondMachine generation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	$(SOURCE_COMMAND)
	@touch $(WORKING_DIR)/bondmachine_target
	@echo -e "$(PJP)$(INFOC)[BondMachine generation end]$(DEFC)"
	@echo

$(WORKING_DIR)/hdl_target:  $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[HDL generation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -create-verilog -verilog-mapfile $(MAPFILE) -verilog-flavor $(BOARD) $(BENCHCORE_ARGS) $(SLOW_ARGS) $(BASYS3_7SEG_ARGS) $(IB_LEDS_ARGS) $(PS2KBD_ARGS) $(VGATEXT_ARGS) $(ETHERBOND_ARGS) $(UDPBOND_ARGS) $(BMAPI_ARGS) $(VERILOG_OPTIONS) $(BMINFO_ARGS)
	echo > $(WORKING_DIR)/bondmachine.sv
	for i in `ls *.v | sort -d` ; do cat $$i >> $(WORKING_DIR)/bondmachine.sv ; done
	rm -f *.v
	echo > $(WORKING_DIR)/bondmachine.vhd
	for i in `ls *.vhd | sort -d` ; do cat $$i >> $(WORKING_DIR)/bondmachine.vhd ; done
	rm -f *.vhd
	@touch $(WORKING_DIR)/hdl_target
	@echo -e "$(PJP)$(INFOC)[HDL generation end]$(DEFC)"
	@echo

$(WORKING_DIR)/bmapp_target: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[BondMachine App compiling begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	rm -rf $(WORKING_DIR)/app
	mkdir -p $(WORKING_DIR)/app
	cp $(BMAPI_GOAPP) $(WORKING_DIR)/app
	cd $(WORKING_DIR)/app ; go mod init $(BMAPI_GOMOD) ; go mod edit -replace git.fisica.unipg.it/bondmachine/bmapiusbuart.git=../bmapi ; go mod tidy
	cd $(WORKING_DIR)/app ; go build
	@touch $(WORKING_DIR)/bmapp_target
	@echo -e "$(PJP)$(INFOC)[BondMachine App compiling end]$(DEFC)"
	@echo

bmapprun: $(WORKING_DIR)/bmapp_target program | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[BondMachine run App begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cd $(WORKING_DIR)/app ; go run $(BMAPI_GOAPP)
	@echo -e "$(PJP)$(INFOC)[BondMachine run App end]$(DEFC)"
	@echo


show: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[BondMachine diagram show begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -emit-dot $(SHOW_ARGS) $(BMINFO_ARGS) | $(SHOW_RENDERER)
	@echo -e "$(PJP)$(INFOC)[BondMachine diagram show end]$(DEFC)"
	@echo

report: $(WORKING_DIR)/vivado_design_implementation  | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[BondMachine report begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@echo -e "{" > $(WORKING_DIR)/report.json
	@echo -e '\t"cps": '`bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -enum-processors`',' >> $(WORKING_DIR)/report.json
	@echo -e '\t"bonds": '`bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -enum-bonds`',' >> $(WORKING_DIR)/report.json
	@echo -e '\t"luts": '`grep -F -e LUTs $(WORKING_DIR)/bmaccelerator/bmaccelerator.runs/impl_1/bm_design_wrapper_utilization_placed.rpt | cut -d '|' -f 3 | sed 's/ //g'`',' >> $(WORKING_DIR)/report.json
	@echo -e '\t"regs": '`grep -F -e 'Slice Registers' $(WORKING_DIR)/bmaccelerator/bmaccelerator.runs/impl_1/bm_design_wrapper_utilization_placed.rpt | cut -d '|' -f 3 | sed 's/ //g' | head -n 1`',' >> $(WORKING_DIR)/report.json
	@echo -e '\t"power": '`grep -F -e 'bondmachineip_0' $(WORKING_DIR)/bmaccelerator/bmaccelerator.runs/impl_1/bm_design_wrapper_power_routed.rpt | cut -d "|" -f 3 | sed 's/ //g'| head -n 1`',' >> $(WORKING_DIR)/report.json
ifeq ($(BOARD),zedboard)
	@echo -e '\t"clock_freq": 100' >> $(WORKING_DIR)/report.json
endif
ifeq ($(BOARD),ebaz4205)
	@echo -e '\t"clock_freq": 50' >> $(WORKING_DIR)/report.json
endif
	@echo -e "}" >> $(WORKING_DIR)/report.json
	@echo -e "$(PJP)$(INFOC)[BondMachine report end]$(DEFC)"
	@echo

simulate: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
ifndef SIMBOX_FILE
	$(error SIMBOX_FILE is undefined)
endif
ifndef SIM_INTERACTIONS
	$(error SIM_INTERACTIONS is undefined)
endif
	@echo -e "$(PJP)$(INFOC)[BondMachine simulation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cp $(SIMBOX_FILE) $(WORKING_DIR)
	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -sim -simbox-file $(WORKING_DIR)/$(SIMBOX_FILE) -sim-interactions $(SIM_INTERACTIONS) $(SIM_OPTIONS) | tee $(WORKING_DIR)/simulate.out
	@echo -e "$(PJP)$(INFOC)[BondMachine simulation end]$(DEFC)"
	@echo


simbatch: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
ifndef SIMBATCH_INPUT_DATASET
	$(error SIMBATCH_INPUT_DATASET is undefined)
endif
ifndef SIMBATCH_OUTPUT_DATASET
	$(error SIMBATCH_OUTPUT_DATASET is undefined)
endif
ifndef SIMBATCH_ITERACTIONS
	$(error SIMBATCH_ITERACTIONS is undefined)
endif
	@echo -e "$(PJP)$(INFOC)[BondMachine simbatch begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	./simbatch.py -w $(WORKING_DIR) -i $(SIMBATCH_INPUT_DATASET) -o $(SIMBATCH_OUTPUT_DATASET) -s $(SIMBATCH_ITERACTIONS) $(SIMBATCH_ARGS)
	@echo -e "$(PJP)$(INFOC)[BondMachine simbatch end]$(DEFC)"
	@echo

simvideo: simulate
	@echo -e "$(PJP)$(INFOC)[Simulation video creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	rm -f graphviz.mp4
	./Makevideo
	mplayer -fs graphviz.mp4
	@echo -e "$(PJP)$(INFOC)[Simulation video creation end]$(DEFC)"
	@echo

emulate: $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[BondMachine emulation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	$(EMU_PREREQUISITES) &
	@sleep 1
	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -emu $(EMU_OPTIONS)
	@echo -e "$(PJP)$(INFOC)[BondMachine emmulation end]$(DEFC)"
	@echo


.PHONY: regressionhdl
regressionhdl: $(HDL_REGRESSION_TARGETS) | silent
ifneq ($(HDL_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[HDL Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(HDL_REGRESSION); do echo -n "$$rfile" ; ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -e "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || (echo -e "$(ERRC)$(SEND)[ Failed ]$(DEFC)" ; exit 1) ; done
	@echo -e "$(PJP)$(INFOC)[HDL Regression end]$(DEFC)"
	@echo
endif

.PHONY: regressionbm
regressionbm: $(BM_REGRESSION_TARGETS) | silent
ifneq ($(BM_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(BM_REGRESSION); do echo -n "$$rfile" ; ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -e "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || (echo -ne "$(ERRC)$(SEND)[ Failed ]$(DEFC)" ; exit 1) ; done
	@echo -e "$(PJP)$(INFOC)[BondMachine Regression end]$(DEFC)"
	@echo
endif

.PHONY: regressionsim
regressionsim: $(SIM_REGRESSION_TARGETS) | silent
ifneq ($(SIM_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[Simulation Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(SIM_REGRESSION); do echo -n "$$rfile" ; ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -e "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || (echo -ne "$(ERRC)$(SEND)[ Failed ]$(DEFC)" ; exit 1) ; done
	@echo -e "$(PJP)$(INFOC)[Simulation Regression end]$(DEFC)"
	@echo
endif

.PHONY: regression
regression: regressionbm regressionhdl regressionsim

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

.PHONY: regressionsimdiff
regressionsimdiff: $(SIM_REGRESSION_TARGETS)
ifneq ($(SIM_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[Simulation Regression begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(SIM_REGRESSION); do ( cmp $(WORKING_DIR)/$$rfile $$rfile.reg > /dev/null 2>&1 && echo -ne "$(INFOC)$(SEND)[ Passed ]$(DEFC)" ) || ( vimdiff $(WORKING_DIR)/$$rfile $$rfile.reg ) ; done
	@echo -e "$(PJP)$(INFOC)[Simulation Regression end]$(DEFC)"
	@echo
endif

.PHONY: regressiondiff
regressiondiff: regressionbmdiff regressionhdldiff regressionsimdiff

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

.PHONY: regressionsimreset
regressionsimreset: $(SIM_REGRESSION_TARGETS)
ifneq ($(SIM_REGRESSION_TARGETS), )
	@echo -e "$(PJP)$(INFOC)[Simulation Regression reset begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@for rfile in $(SIM_REGRESSION); do cp $(WORKING_DIR)/$$rfile $$rfile.reg ; echo "$$rfile Resetted" ; done
	@echo -e "$(PJP)$(INFOC)[Simulation Regression reset end]$(DEFC)"
	@echo
endif



.PHONY: regressionreset
regressionreset: regressionbmreset regressionhdlreset regressionsimreset


##### Iverilog gtkwave toolchain

# TODO Convert here to a new toolchain for iverilog
#$(WORKING_DIR)/bondmachine_simulation.sv:  $(WORKING_DIR)/bondmachine_target | $(WORKING_DIR) checkenv
#	cp $(SIMBOX_FILE) $(WORKING_DIR)
#	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -create-verilog -verilog-mapfile $(MAPFILE) -verilog-flavor iverilog $(BENCHCORE_ARGS) $(VERILOG_OPTIONS) -verilog-simulation -simbox-file $(WORKING_DIR)/$(SIMBOX_FILE) -sim-interactions $(SIM_INTERACTIONS)
#	echo > $(WORKING_DIR)/bondmachine_simulation.sv
#	for i in `ls *.v | sort -d` ; do cat $$i >> $(WORKING_DIR)/bondmachine_simulation.sv ; done
#	rm -f *.v


# TODO Convert here to a new toolchain for iverilog gtkwave
#simverilog: $(WORKING_DIR)/bondmachine_simulation.sv | $(WORKING_DIR) checkenv
#	iverilog $(WORKING_DIR)/bondmachine_simulation.sv -o $(WORKING_DIR)/bondmachine_simulation.vvp
#	vvp $(WORKING_DIR)/bondmachine_simulation.vvp 
#
#simgtkwave: $(WORKING_DIR)/bondmachine_simulation.sv | $(WORKING_DIR) checkenv
#	bondmachine -bondmachine-file $(WORKING_DIR)/bondmachine.json -show-program-alias
#	mv p*.alias $(WORKING_DIR)
#	iverilog $(WORKING_DIR)/bondmachine_simulation.sv -o $(WORKING_DIR)/bondmachine_simulation.vvp
#	vvp $(WORKING_DIR)/bondmachine_simulation.vvp 
#	gtkwave $(WORKING_DIR)/bondmachine.vcd

##### Quartus toolchain targets

$(WORKING_DIR)/$(BOARD).sdc: | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - copy constraints begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cp $(BOARD).sdc $(WORKING_DIR)
	@touch $(WORKING_DIR)/constraint_target
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - copy constraints end]$(DEFC)"
	@echo

$(WORKING_DIR)/quartus_creation:  $(WORKING_DIR)/$(BOARD).sdc $(WORKING_DIR)/hdl_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - project creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cat $(ROOTDIR)/$(BOARD)_template_creation.tcl >> $(WORKING_DIR)/quartus-script-creation.tcl
	bash -c "cd $(WORKING_DIR) ; quartus_sh -t quartus-script-creation.tcl"
	@touch $(WORKING_DIR)/quartus_creation
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - project creation end]$(DEFC)"
	@echo

$(WORKING_DIR)/quartus_synthesis: $(WORKING_DIR)/quartus_creation | $(WORKING_DIR)  checkenv
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - synthesis begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@touch $(WORKING_DIR)/quartus_synthesis
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - synthesis end]$(DEFC)"
	@echo

$(WORKING_DIR)/quartus_implementation: $(WORKING_DIR)/quartus_synthesis | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - implementation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@touch $(WORKING_DIR)/quartus_implementation
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - implementation end]$(DEFC)"
	@echo

$(WORKING_DIR)/quartus_bitstream: $(WORKING_DIR)/quartus_implementation | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - write bitstream begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@touch $(WORKING_DIR)/quartus_bitstream
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - write bitstream end]$(DEFC)"
	@echo

.PHONY: $(WORKING_DIR)/quartus_program
$(WORKING_DIR)/quartus_program: $(WORKING_DIR)/quartus_bitstream | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - programming begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@touch $(WORKING_DIR)/quartus_program
	@echo -e "$(PJP)$(INFOC)[Quartus toolchain - programming end]$(DEFC)"
	@echo

##### Icestorm toolchain targets

$(WORKING_DIR)/$(BOARD).pcf: | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - copy constraints begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cp $(BOARD).pcf $(WORKING_DIR)
	@touch $(WORKING_DIR)/constraint_target
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - copy constraints end]$(DEFC)"
	@echo

$(WORKING_DIR)/icestorm_creation:  $(WORKING_DIR)/$(BOARD).pcf $(WORKING_DIR)/hdl_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - project creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	@touch $(WORKING_DIR)/icestorm_creation
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - project creation end]$(DEFC)"
	@echo

$(WORKING_DIR)/icestorm_synthesis: $(WORKING_DIR)/icestorm_creation | $(WORKING_DIR)  checkenv
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - synthesis begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	yosys -p "synth_ice40 -top bondmachine_main -json $(WORKING_DIR)/bondmachine_icestorm.json" $(WORKING_DIR)/bondmachine.sv
	@touch $(WORKING_DIR)/icestorm_synthesis
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - synthesis end]$(DEFC)"
	@echo

$(WORKING_DIR)/icestorm_implementation: $(WORKING_DIR)/icestorm_synthesis | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - implementation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	nextpnr-ice40 -r --$(BOARD_MODEL) --json $(WORKING_DIR)/bondmachine_icestorm.json --package $(BOARD_PACKAGE) --asc $(WORKING_DIR)/bondmachine.asc --opt-timing --pcf $(WORKING_DIR)/$(BOARD).pcf
	@touch $(WORKING_DIR)/icestorm_implementation
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - implementation end]$(DEFC)"
	@echo

$(WORKING_DIR)/icestorm_bitstream: $(WORKING_DIR)/icestorm_implementation | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - write bitstream begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	icepack $(WORKING_DIR)/bondmachine.asc $(WORKING_DIR)/bondmachine.bin
	@touch $(WORKING_DIR)/icestorm_bitstream
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - write bitstream end]$(DEFC)"
	@echo

.PHONY: $(WORKING_DIR)/icestorm_program
$(WORKING_DIR)/icestorm_program: $(WORKING_DIR)/icestorm_bitstream | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - programming begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
ifeq ($(BOARD),icefun)
	iceFUNprog $(WORKING_DIR)/bondmachine.bin
endif
ifeq ($(BOARD),icebreaker)
	iceprog $(WORKING_DIR)/bondmachine.bin
endif

	@touch $(WORKING_DIR)/icestorm_program
	@echo -e "$(PJP)$(INFOC)[Icestorm toolchain - programming end]$(DEFC)"
	@echo

##### Vivado toolchain targets

$(WORKING_DIR)/$(BOARD).xdc: | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - copy constraints begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cp $(BOARD).xdc $(WORKING_DIR)
	@touch $(WORKING_DIR)/constraint_target
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - copy constraints end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_creation:  $(WORKING_DIR)/$(BOARD).xdc $(WORKING_DIR)/hdl_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - project creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo  "set origin_dir \"$(CURRENT_DIR)/$(WORKING_DIR)\"" > $(WORKING_DIR)/vivado-script-creation.tcl
	cat $(ROOTDIR)/$(BOARD)_template_creation.tcl >> $(WORKING_DIR)/vivado-script-creation.tcl
	rm -rf $(WORKING_DIR)/bondmachine
	rm -rf $(WORKING_DIR)/vivado.*
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-creation.tcl"
	@touch $(WORKING_DIR)/vivado_creation
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - project creation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_synthesis: $(WORKING_DIR)/vivado_creation | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - synthesis begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo "open_project \"$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.xpr\"" > $(WORKING_DIR)/vivado-script-synthesis.tcl
	cat $(ROOTDIR)/$(BOARD)_template_synthesis.tcl >> $(WORKING_DIR)/vivado-script-synthesis.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-synthesis.tcl"
	@touch $(WORKING_DIR)/vivado_synthesis
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - synthesis end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_implementation: $(WORKING_DIR)/vivado_synthesis | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - implementation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo "open_project \"$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.xpr\"" > $(WORKING_DIR)/vivado-script-implementation.tcl
	cat $(ROOTDIR)/$(BOARD)_template_implementation.tcl >> $(WORKING_DIR)/vivado-script-implementation.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-implementation.tcl"
	@touch $(WORKING_DIR)/vivado_implementation
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - implementation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_bitstream: $(WORKING_DIR)/vivado_implementation | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - write bitstream begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	echo "open_project \"$(CURRENT_DIR)/$(WORKING_DIR)/bondmachine/bondmachine.xpr\"" > $(WORKING_DIR)/vivado-script-bitstream.tcl
	cat $(ROOTDIR)/$(BOARD)_template_bitstream.tcl >> $(WORKING_DIR)/vivado-script-bitstream.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-bitstream.tcl"
	@touch $(WORKING_DIR)/vivado_bitstream
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - write bitstream end]$(DEFC)"
	@echo

.PHONY: $(WORKING_DIR)/vivado_program
$(WORKING_DIR)/vivado_program: $(WORKING_DIR)/vivado_bitstream | $(WORKING_DIR) checkenv
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
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-program.tcl"
	@touch $(WORKING_DIR)/vivado_program
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - programming end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_accelerator:  $(WORKING_DIR)/hdl_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - IP accelerator creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
ifeq ($(BMAPI_FLAVOR),)
	$(error BMAPI_FLAVOR is undefined)
endif
	cat $(ROOTDIR)/$(BOARD)_$(BMAPI_FLAVOR)_template_accelerator.tcl >> $(WORKING_DIR)/vivado-script-accelerator.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-accelerator.tcl"
	cp -a $(WORKING_DIR)/bondmachine.sv $(WORKING_DIR)/ip_repo/bondmachineip_1.0/hdl/bondmachine.sv
ifeq ($(BMAPI_FLAVOR), axist)
	rm -f $(WORKING_DIR)/ip_repo/bondmachineip_1.0/hdl/bondmachineip_v1_0_M00_AXIS.v
	rm -f $(WORKING_DIR)/ip_repo/bondmachineip_1.0/hdl/bondmachineip_v1_0_S00_AXIS.v
	rm -f $(WORKING_DIR)/ip_repo/bondmachineip_1.0/hdl/bondmachineip_v1_0.v
endif
ifeq ($(BMAPI_FLAVOR),aximm)	
	# Comments
	cp -a $(ROOTDIR)/vivadoAXIcomment.sh $(WORKING_DIR)/vivadoAXIcomment.sh
	bash -c "cd $(WORKING_DIR) ; ./vivadoAXIcomment.sh"
	# Insert the AXI code
	bash -c "cd $(WORKING_DIR) ; sed -i -e '/Add user logic here/r aux/axipatch.txt' ./ip_repo/bondmachineip_1.0/hdl/bondmachineip_v1_0_S00_AXI.v"
	bash -c "cd $(WORKING_DIR) ; sed -i -e '/Users to add ports here/r aux/designexternal.txt' ./ip_repo/bondmachineip_1.0/hdl/bondmachineip_v1_0_S00_AXI.v"
	bash -c "cd $(WORKING_DIR) ; sed -i -e '/Users to add ports here/r aux/designexternal.txt' ./ip_repo/bondmachineip_1.0/hdl/bondmachineip_v1_0.v"
	bash -c "cd $(WORKING_DIR) ; sed -i -e '/bondmachineip_v1_0_S00_AXI_inst/r aux/designexternalinst.txt' ./ip_repo/bondmachineip_1.0/hdl/bondmachineip_v1_0.v"
endif
	@touch $(WORKING_DIR)/vivado_accelerator
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - IP accelerator creation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_design_creation: $(WORKING_DIR)/$(BOARD).xdc $(WORKING_DIR)/vivado_accelerator | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
ifeq ($(BMAPI_FLAVOR),)
	$(error BMAPI_FLAVOR is undefined)
endif	
	cat $(ROOTDIR)/$(BOARD)_$(BMAPI_FLAVOR)_template_design_creation.tcl >> $(WORKING_DIR)/vivado-script-design-creation.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-design-creation.tcl"
	@touch $(WORKING_DIR)/vivado_design_creation
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design creation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_design_synthesis:  $(WORKING_DIR)/vivado_design_creation | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design synthesis begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cat $(ROOTDIR)/$(BOARD)_template_design_synthesis.tcl >> $(WORKING_DIR)/vivado-script-design-synthesis.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-design-synthesis.tcl"
	@touch $(WORKING_DIR)/vivado_design_synthesis
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design synthesis end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_design_implementation:  $(WORKING_DIR)/vivado_design_synthesis | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design implementation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cat $(ROOTDIR)/$(BOARD)_template_design_implementation.tcl >> $(WORKING_DIR)/vivado-script-design-implementation.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-design-implementation.tcl"
	@touch $(WORKING_DIR)/vivado_design_implementation
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design implementation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_design_bitstream:  $(WORKING_DIR)/vivado_design_implementation | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design bitstream begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cat $(ROOTDIR)/$(BOARD)_template_design_bitstream.tcl >> $(WORKING_DIR)/vivado-script-design-bitstream.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-design-bitstream.tcl"
	@touch $(WORKING_DIR)/vivado_design_bitstream
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - design bitstream end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_export_hardware:  $(WORKING_DIR)/vivado_design_bitstream | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - export hardware begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	cat $(ROOTDIR)/$(BOARD)_template_design_export_hardware.tcl >> $(WORKING_DIR)/vivado-script-design-export-hardware.tcl
	bash -c "cd $(WORKING_DIR) ; vivado -mode batch -source vivado-script-design-export-hardware.tcl"	
	@touch $(WORKING_DIR)/vivado_export_hardware
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - export hardware end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_devicetree:  $(WORKING_DIR)/vivado_export_hardware | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - devicetree creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
	bash -c "cd $(WORKING_DIR) ; git clone https://github.com/Xilinx/device-tree-xlnx"
	bash -c "cd $(WORKING_DIR)/device-tree-xlnx ; git checkout xilinx-v$(VIVADO_VERSION)"
	cat $(ROOTDIR)/$(BOARD)_template_design_devicetree.tcl >> $(WORKING_DIR)/vivado-script-design-devicetree.tcl
	bash -c "cd $(WORKING_DIR) ; xsct vivado-script-design-devicetree.tcl"	
	bash -c "cd $(WORKING_DIR)/dts ; gcc -I dts -E -nostdinc -undef -DDTS -x assembler-with-cpp -o full-system.dts system-top.dts"
	bash -c "cd $(WORKING_DIR)/dts ; dtc -O dtb -o bondmachine.dtb full-system.dts"
	@touch $(WORKING_DIR)/vivado_devicetree
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - devicetree creation end]$(DEFC)"
	@echo

$(WORKING_DIR)/vivado_kernel_module:  $(WORKING_DIR)/hdl_target | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - kernel module creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
ifeq ($(CC_KDIR),)
	$(error CC_KDIR is undefined)
endif
ifeq ($(CC_ARCH),)
	$(error CC_ARCH is undefined)
endif
ifeq ($(CC_TRIPLET),)
	$(error CC_TRIPLET is undefined)
else
#ifeq (, $(shell which $(CC_TRIPLET)-gcc 2> /dev/null ))
# 	$(error "cross compiler in not installed or not in PATH")
#endif
endif

	@echo "obj-m += bm.o" > $(WORKING_DIR)/module/Makefile
	@echo "KDIR = $(CC_KDIR)" >> $(WORKING_DIR)/module/Makefile
	@echo "all:" >> $(WORKING_DIR)/module/Makefile
	@echo '	make ARCH=$(CC_ARCH) CROSS_COMPILE=$(CC_TRIPLET)- -C $$(KDIR)  M=$$(shell pwd) modules' >> $(WORKING_DIR)/module/Makefile
	@echo "clean:" >> $(WORKING_DIR)/module/Makefile
	@echo '	make ARCH=$(CC_ARCH) CROSS_COMPILE=$(CC_TRIPLET)- -C $$(KDIR)  M=$$(shell pwd) clean' >> $(WORKING_DIR)/module/Makefile

	@make --no-print-directory  -C $(WORKING_DIR)/module

	@touch $(WORKING_DIR)/vivado_kernel_module
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - kernel module creation end]$(DEFC)"
	@echo

.PHONY: $(WORKING_DIR)/vivado_buildroot
$(WORKING_DIR)/vivado_buildroot: $(WORKING_DIR)/vivado_devicetree $(WORKING_DIR)/vivado_kernel_module | $(WORKING_DIR) checkenv
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - buildroot BR2 creation begin]$(DEFC) - $(WARNC)[Target: $@] $(DEFC)"
ifneq ($(BOARD),zedboard)
ifneq ($(BOARD),ebaz4205)
	$(error $(BOARD) has not (yet?) support for buildroot)
endif
endif
ifeq ($(BR_DEST),)
	$(error Buildroot BR2 destination directory (BR_DEST) is undefined)
endif
ifeq (, $(shell which git 2> /dev/null ))
	$(error "git in not installed or not in PATH")
endif

	rm -rf $(BR_DEST)
	git clone https://github.com/BondMachineHQ/bondmachine_$(BOARD)_buildroot.git $(BR_DEST)

ifneq ($(BR_ROOT_PASS),)
	echo "BR2_TARGET_GENERIC_ROOT_PASSWD=\"$(BR_ROOT_PASS)\"" >> $(BR_DEST)/configs/bm_zed_defconfig
endif

	mkdir $(BR_DEST)/dts
	cp $(WORKING_DIR)/dts/full-system.dts $(BR_DEST)/dts

	cp $(WORKING_DIR)/bmaccelerator/bmaccelerator.runs/impl_1/bm_design_wrapper.bin $(BR_DEST)/bmfiles/bondmachine.bin

ifneq ($(BR_AUTHORIZED_KEYS),)
	mkdir -p $(BR_DEST)/overlay/root/.ssh/
	cp -a $(BR_AUTHORIZED_KEYS) $(BR_DEST)/overlay/root/.ssh/authorized_keys
endif

	mkdir -p $(BR_DEST)/overlay/lib/modules/4.16.0/extra
	cp $(WORKING_DIR)/module/bm.ko $(BR_DEST)/overlay/lib/modules/4.16.0/extra

# TODO Se c'e' una bmapp specificata nei makefile, la inseriremo nell'overlay di buildroot, ma bmapp non e' una dipendenza	

	@touch $(WORKING_DIR)/vivado_buildroot
	@echo -e "$(PJP)$(INFOC)[Vivado toolchain - buildroot BR2 creation end]$(DEFC)"
	@echo





#### Cleanups and Checks

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
 
.PHONY: checkenv
checkenv:
ifndef WORKING_DIR
	$(error WORKING_DIR is undefined)
endif

ifeq ($(BOARDOK),)
	$(error BOARD is undefined)
endif
ifeq ($(BOARD),none)
	$(error BOARD is undefined)
endif

ifeq ($(MAKECMDGOALS), project)

ifeq ($(TOOLCHAIN),vivado)
ifeq (, $(shell which vivado 2> /dev/null ))
 	$(error "vivado in not installed or not in PATH")
endif
ifeq (, $(shell which xsct 2> /dev/null ))
 	$(error "xsct in not installed or not in PATH")
endif
ifeq (, $(shell which dtc 2> /dev/null ))
 	$(error "dtc in not installed or not in PATH")
endif
endif
endif
# TODO others toolchains



#ifeq (, $(shell which git 2> /dev/null ))
# 	$(error "No git in PATH")
#endif

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
