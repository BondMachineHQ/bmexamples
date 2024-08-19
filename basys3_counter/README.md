This example shows a simple binary counter implemented in Basm, the BondMachine assembly. The example uses the 16 Basys3 LEDs to show the counter. The counter is implemented in the file `counter.basm`:

```asm
%section code .romtext
    entry _start ; Entry point
_start:
    clr     r0   ; Clear the counter
loop:
    inc    r0    ; Increment the counter
    r2o    r0,o0 ; Output the counter to the LEDs
    j      loop  ; Jump back to the loop

%endsection

%meta cpdef     cpu romcode: code, ramsize:8
%meta ioatt     testio cp: cpu, index:0, type:output
%meta ioatt     testio cp: bm, index:0, type:output
%meta bmdef     global registersize:16
```

The connection to the leds is done in the file `default_maps.json`. The file maps the output `o0` of the BondMachine to the 16 LEDs of the Basys3 board:

```json
{
"Assoc" : {
	"clk" : "clk",
	"reset" : "btnC",
	"o0": "[15:0] led"
	}
}
```

The configuration file `.config` specifies all the necessary information to build the project. The BOARD_SLOW variable is set to true so the counter is visible in the LEDs. 

In order to build the project, the following prerequisites must be met:
 - Vivado installed and in the PATH
 - The BondMachine tools installed and in the PATH
 - The Basys3 board connected to the computer

To build the project and program the Basys3 board, run the following command:

```bash
make apply
make program
```

After some time, depending on the computer, the counter will be visible in the LEDs of the Basys3 board.