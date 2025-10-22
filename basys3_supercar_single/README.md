# Basys3 Supercar Single Board Example

In this example, we will create a simple optical effect with the leds of the Basys3 board. This consists of a single switched on led that moves from left to right and back again. The name of the example is *supercar* in honor of the famous car from the TV series Knight Rider.

The example is built around a single BondMachine cp that drives the leds. The cp code is implemented in basm and is located in the file `test.basm`, which is as follows:

```asm
%section kittsingle .romtext iomode:async
        entry _start    ; Entry point
_start:
    rsets16 r3,1 ; initial led position, r3 holds the led pattern as 16 bit register
    rsets16 r4,0 ; direction - 0=left , otherwise=right
wait:
    rsets16 r0, 10000 ; wait time1
    rsets16 r1, 1000 ; wait time2
    call8s sleep ; call sleep from the library
    jz r4, goingl ; check direction and jump accordingly
goingr:
    cir r3 ; shift right
    jz r3, setl ; if r3 is zero, set direction to left
    j print
setl:
    rsets16 r4,0 ; set direction to left
    rsets16 r3,1 ; set r3 to first led
    j print
goingl:
    cil r3 ; shift left
    jz r3, setr ; if r3 is zero, set direction to right
    j print
setr:
    rsets16 r4, 1 ; set direction to right
    rsets16 r3, 32768 ; set r3 to last led
    j print
print:
    mov o0, r3 ; move led pattern to output
    j wait
%endsection
```

The comments in the code explain how it works. The cp code uses a simple algorithm to move a single bit left and right across a 16-bit register, which is then output to the leds.

The basm metadata is located in the file `test.bmeta` and describes the cp and its peripherals:

```asm
%meta cpdef cpu1 romcode: kittsingle
%meta bmdef global  registersize:16, mapclk:clk, mapreset:btnC
%meta ioatt bond1 cp: bm, index:0, type:output, mapfrom:0, mapto:15, mapname: led
%meta ioatt bond1 cp: cpu1, index:0, type:output
```

To build and run the example, use the following commands within the example directory:

```bash
make apply
make program
```

This will compile the cp code, generate the necessary files, and program the Basys3 board. Once programmed, you should see a single led moving back and forth across the led array on the board, creating the desired optical effect.

![Basys3 Supercar Single Board Example](effect.gif)