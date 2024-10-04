# Led Rotation on the Icebreaker Board



```asm
%section code .romtext
  entry _start    ; Entry point
_start:
  rset	r0,1
  r2o	r0,o0
  nop
  rset	r0,4
  r2o	r0,o0
  nop
  rset	r0,2
  r2o	r0,o0
  nop
  rset	r0,8
  r2o	r0,o0
  j	_start

%endsection

%meta cpdef	cpu	romcode: code
%meta ioatt     testio cp: cpu, index:0, type:output
%meta ioatt     testio cp: bm, index:0, type:output
%meta bmdef	global registersize:4
```

if the following requirements are met:

- the FPGA tools for the specific board installed and in the PATH
- the board connected to the computer

then the example can be build and run using the following commands within the `icebreaker_rotation` directory:

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