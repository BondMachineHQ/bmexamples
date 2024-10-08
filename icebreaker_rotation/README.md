# Led Rotation on the Icebreaker Board

The purpose of this project is to demonstrate the use of the `icebreaker` board a BondMachine architecture. It is a very simple one, with only one processor and a few instructions. The processor is connected to a single output, which is used to control the rotation of the LEDs on the board. The code, written in the BondMachine assembly language, is very simple. It sets the output to different values and then jumps back to the beginning. This causes the LEDs to rotate.

```asm
%section code .romtext
  entry _start    ; Entry point
_start:
  rset  r0,1
  r2o   r0,o0
  nop
  rset  r0,4
  r2o   r0,o0
  nop
  rset  r0,2
  r2o   r0,o0
  nop
  rset  r0,8
  r2o   r0,o0
  j _start

%endsection

%meta cpdef	cpu	romcode: code
%meta ioatt     testio cp: cpu, index:0, type:output
%meta ioatt     testio cp: bm, index:0, type:output
%meta bmdef	global registersize:4
```

After cloning the repository:

```bash
git clone https://github.com/BondMachineHQ/bmexamples.git
cd bmexamples/icebreaker_rotation
```

The code can be found in the file `rotate.basm` in the `icebreaker_rotation` directory alongside all the necessary files to build and run the example. In order to everything to work, there are a few requirements that need to be met:

- the BondMachine tools are installed
- the FPGA open source toolchain for the Lattice boards are installed
- the board connected to the computer

The example can be build and run using the following commands within the `icebreaker_rotation` directory:

```bash
make apply
make program
```

Following is the output of the `make specs` command. It shows the details of the generated architecture in terms of the number of instructions, registers, ROM memory, and other details.

```text
Register size: 4
Processors:
  0:
    Domain ID: 0
    ROM width/Word size: 7
    ROM depth: 16
    RAM width: 4
    RAM depth: 1
    Registers: 2
    Inputs: 0
    Outputs: 1
    ISA:
        Istructions: 4(2)
        j(6),nop(2),r2o(4),rset(7)
    Modes: ha
    ROM Code:
      000 - 1100001 - rset r0 1
      001 - 1000000 - r2o r0 o0
      002 - 0100000 - nop 
      003 - 1100100 - rset r0 4
      004 - 1000000 - r2o r0 o0
      005 - 0100000 - nop 
      006 - 1100010 - rset r0 2
      007 - 1000000 - r2o r0 o0
      008 - 0100000 - nop 
      009 - 1101000 - rset r0 8
      010 - 1000000 - r2o r0 o0
      011 - 0000000 - j 0
    ROM Data:
```
