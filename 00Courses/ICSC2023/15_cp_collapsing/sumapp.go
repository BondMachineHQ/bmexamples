package main

import (
	"log"
	"time"

	bmapi "git.fisica.unipg.it/bondmachine/bmapiusbuart.git"
	tr "github.com/BondMachineHQ/bmapiuarttransceiver"
)

func main() {

	if ba, err := bmapi.AcceleratorInit("/dev/ttyUSB1", tr.UartTransceiver); err != nil {
		log.Printf("AcceleratorInit failed: %v", err)
		return
	} else {

		ba.WaitConnection()

		var icheck uint8 = 0

		log.Printf("Test starting")

		for j := 0; j < 4; j++ {
			for i := 0; i < 4; i++ {

				time.Sleep(10 * time.Millisecond)

				for {
					if err := ba.BMr2o(0, uint8(i)); err == nil {
						break
					} else {
						time.Sleep(50 * time.Millisecond)
					}
				}

				time.Sleep(time.Millisecond * 50)

				for {
					if check, err := ba.BMi2r(0); err == nil {
						icheck = check
						break
					} else {
						time.Sleep(50 * time.Millisecond)
					}
				}

				if uint8(i+1) != icheck {
					log.Printf("Got the wrong responce from FPGA expected %d but got %d", i+1, icheck)
				} else {
					log.Printf("test: ok expected %d found %d\n", i+1, icheck)
				}
			}
		}

		time.Sleep(time.Second)

		ba.AcceleratorStop()
	}
}
