This example shows a simple shell that give commends to turn on and off a LED of the Basys3 board. The commands are: `on` and `off`. The shell is implemented in Basm, the BondMachine assembly. The example also use the VGA and the keyboard modules to show the shell in the screen and to get the commands from the user.

The shell is implemented in the file `shell.basm`. The source file is well documented and it is easy to understand. To work, the shell needs additional files that are in the `library` directory. 

Upon programmed, the basys3 should be cooneccted to a VGA monitor and a USB keyboard. A box in the upper left corner of the screen will show the shell. The user can type the commands `on` and `off` to turn on and off the LED 0 of the Basys3 board. The shell will also show the result of the command in the screen. Other commands will be ignored.

