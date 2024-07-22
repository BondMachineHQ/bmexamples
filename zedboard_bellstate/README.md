This example demonstrates how to use the ZedBoard and the BondMachine framework to generate a quantum circuit that prepares a Bell state. The Bell state is a maximally entangled state of two qubits. The circuit is then executed on the ZedBoard and the results are read back and displayed on the host machine.

The circuit of the Bell state is shown below:

![Bell state circuit](bellstate.png)

The circuit consists of two qubits, q0 and q1. The Hadamard gate is applied to q0, followed by a CNOT gate with q0 as the control and q1 as the target. This translates to the following quantum circuit written in
bmq language:

```
%block code1 .sequential
	qbits	q0,q1
	zero	q0,q1
	h	q0
	cx	q0,q1
%endblock

%meta bmdef global main:code1
```

It worth noting the file `local.mk` in this example. This file is used to specify options for the BondMachine framework. In this case, the file specifies the target device as the ZedBoard and the target language as bmq. The file is shown below:

```
WORKING_DIR=working_dir
CURRENT_DIR=$(shell pwd)
SOURCE_QUANTUM=program.bmq
QUANTUM_APP=working_dir/circuit.c
QUANTUM_ARGS=-build-matrix-seq-hardcoded -hw-flavor seq_hardcoded_complex -app-flavor c_pynqapi_complex -build-app -app-file $(QUANTUM_APP) -emit-bmapi-maps -bmapi-maps-file bmapi.json
BOARD=zedboard
BASM_ARGS=-disable-dynamical-matching -bo $(WORKING_DIR)/bondmachine.bcof -chooser-min-word-size -chooser-force-same-name -dump-requirements $(WORKING_DIR)/requirements.json
MAPFILE=zedboard_maps.json
SHOWARGS=-dot-detail 5
SHOWRENDERER=dot -Txlib
VERILOG_OPTIONS=-comment-verilog -bcof-file $(WORKING_DIR)/bondmachine.bcof
BMREQS=$(WORKING_DIR)/requirements.json
HWOPTIMIZATIONS=onlydestregs,onlysrcregs
include bmapi.mk
include deploy.mk
```

The project can be verified by running the following command:

```
make validate
```

if the project is valid, it can be finalized by running the following command:

```
make apply
```

