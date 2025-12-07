package main

import (
	"bondgo"
)

func test1() {
	var in bondgo.Input
	var out bondgo.Output

	var reg_int uint8

	in = bondgo.Make(bondgo.Input, 2)
	out = bondgo.Make(bondgo.Output, 3)

	for {
		reg_int = bondgo.IORead(in)
		reg_int++
		bondgo.IOWrite(out, reg_int)
	}

	bondgo.Void(in)
	bondgo.Void(out)
}

func test2() {
	var in bondgo.Input
	var out bondgo.Output

	var reg_int uint8

	in = bondgo.Make(bondgo.Input, 3)
	out = bondgo.Make(bondgo.Output, 4)

	for {
		reg_int = bondgo.IORead(in)
		reg_int++
		bondgo.IOWrite(out, reg_int)
	}

	bondgo.Void(in)
	bondgo.Void(out)
}

func test3() {
	var in bondgo.Input
	var out bondgo.Output

	var reg_int uint8

	in = bondgo.Make(bondgo.Input, 4)
	out = bondgo.Make(bondgo.Output, 5)

	for {
		reg_int = bondgo.IORead(in)
		reg_int++
		bondgo.IOWrite(out, reg_int)
	}

	bondgo.Void(in)
	bondgo.Void(out)
}

func main() {
	var externalin bondgo.Input
	var externalout bondgo.Output

	var in bondgo.Input
	var out bondgo.Output

	var reg_int1 uint8
	var reg_int2 uint8

	externalin = bondgo.Make(bondgo.Input, 1)
	externalout = bondgo.Make(bondgo.Output, 6)

	in = bondgo.Make(bondgo.Input, 5)
	out = bondgo.Make(bondgo.Output, 2)

	go test1()
	go test2()
	go test3()

	for {
		reg_int1 = bondgo.IORead(externalin)
		bondgo.IOWrite(out, reg_int1)
		reg_int2 = bondgo.IORead(in)
		bondgo.IOWrite(externalout, reg_int2)
	}

	bondgo.Void(in)
	bondgo.Void(out)
	bondgo.Void(externalin)
	bondgo.Void(externalout)
}
