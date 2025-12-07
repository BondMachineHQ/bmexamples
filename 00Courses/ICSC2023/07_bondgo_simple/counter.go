package main

import (
	"bondgo"
)

func main() {
	var outgoing bondgo.Output

	var reg_int uint8

	outgoing = bondgo.Make(bondgo.Output, 3)

	reg_int = 0

	for {
		bondgo.IOWrite(outgoing, reg_int)
		reg_int++
	}

	bondgo.Void(outgoing)
}
