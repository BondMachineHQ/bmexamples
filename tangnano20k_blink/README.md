 # Tang Nano 20K LED Blink Example
 
 This example blinks the Tang Nano 20K's active-low LED0 using a BondMachine-generated design. The 27 MHz clock is on pin 4, LED0 is on pin 15, and reset is connected to pin 88 without polarity inversion. It is one of the simplest BondMachine architectures, with 3 instructions, 2 one-bit registers, and a small ROM. The example originates from the following BASM code:

```asm
%section code .romtext
	entry _start    ; Entry point
_start:
	inc	r0	; Increment register 0
	r2o	r0,o0	; Write register 0 to output port
	j	_start	; Jump to _start
%endsection

%meta cpdef	cpu	romcode: code
%meta ioatt	testio	cp:cpu, index:0, type:output
%meta ioatt	testio	cp:bm, index:0, type:output
%meta bmdef	global	registersize:1
```

The example is simple, it increments a register and writes it to the output port. The program is executed in a loop, so the output port will blink. The example is also used to demonstrate the use of the `ioatt` meta-attribute, which is used to define the input/output ports of the architecture. The `bmdef` meta-attribute is used to define the size of the register in the architecture. The `meta` attributes are used to define the architecture, and the `section` and `endsection` directives are used to define the program code. The program code is written in BASM assembly language, which is a simple assembly language that is used to define the program code of the architecture.

if the following requirements are met:

- the FPGA tools for the specific board installed and in the PATH
- the board connected to the computer

then the example can be build and run using the following commands within the `[boardname]_blink` directory:

```bash
make apply
make program
```

Following is the output of the `make specs` command. It shows the details of the generated architecture in terms of the number of instructions, registers, ROM memory, and other details.
It shows how tiny the architecture is, with only 3 instructions, 2 registers, and a small ROM memory.

```text
Register size: 1
Processors:
  0:
    Domain ID: 0
    ROM width/Word size: 4
    ROM depth: 4
    RAM width: 1
    RAM depth: 1
    Registers: 2
    Inputs: 0
    Outputs: 1
    ISA:
        Istructions: 3(2)
        inc(3),j(4),r2o(4)
    Modes: ha
    ROM Code:
      000 - 0000 - inc r0
      001 - 1000 - r2o r0 o0
      002 - 0100 - j 0
    ROM Data:
```