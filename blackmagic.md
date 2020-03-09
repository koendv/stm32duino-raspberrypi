# Black Magic Probe on Raspberry Pi

This document shows how to convert a STM32F103 Blue Pill to a Black Magic Probe gdb server. 
This allows you to download firmware to a processor over USB, set breakpoints, inspect variables, etc. 

## Converting a Blue Pill to a Black Magic Probe

Install udev rules for the BMP. Go to ~/.arduino15/packages/STM32/tools/STM32Tools/1.3.2/tools/linux/ and run ./install.sh

Clone the BMP source git and compile.

	cd ~
	git clone https://github.com/blacksphere/blackmagic
	cd blackmagic/
	make PROBE_HOST=stlink
	cd src/
	
This creates two files, blackmagic_dfu.bin and blackmagic.bin. 

	koen@raspberrypi:~/src/blackmagic/src $ ls -l blackmagic_dfu.bin blackmagic.bin 
	-rwxr-xr-x 1 koen koen 85068 Mar  9 19:16 blackmagic.bin
	-rwxr-xr-x 1 koen koen  7580 Mar  9 19:16 blackmagic_dfu.bin
	
First we install blackmagic_dfu.bin, the DFU bootloader. Connect the Blue Pill for serial download, with Boot0=1, Boot1=0, and connect a USB-Serial adapter with A9 to RX, A10 to TX. Press reset. Then:

	~/.arduino15/packages/STM32/tools/STM32Tools/1.3.2/tools/linux/stm32flash -g 0x8000000 -w blackmagic_dfu.bin /dev/ttyUSB0  
	stm32flash 0.5
	
	http://stm32flash.sourceforge.net/
	
	Using Parser : Raw BINARY
	Interface serial_posix: 57600 8E1
	Version      : 0x22
	Option 1     : 0x00
	Option 2     : 0x00
	Device ID    : 0x0410 (STM32F10xxx Medium-density)
	- RAM        : 20KiB  (512b reserved by bootloader)
	- Flash      : 128KiB (size first sector: 4x1024)
	- Option RAM : 16b
	- System RAM : 2KiB
	Write to memory
	Erasing memory
	Wrote address 0x08001d9c (100.00%) Done.
	
	Starting execution at address 0x08000000... done.
	
With the bootloader installed, set BMP Boot0=0, Boot1=0. Disconnect the USB-Serial adapter. Connect the Blue Pill USB to the Raspberry.
	
	koen@raspberrypi:~/src/blackmagic/src $ lsusb 
	Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
	Bus 001 Device 080: ID 1a86:7523 QinHeng Electronics HL-340 USB-Serial adapter
	Bus 001 Device 060: ID 0482:0011 Kyocera Corp. 
	Bus 001 Device 059: ID 04d9:1818 Holtek Semiconductor, Inc. Keyboard [Diatec Filco Majestouch 2]
	Bus 001 Device 058: ID 046d:c05a Logitech, Inc. M90/M100 Optical Mouse
	Bus 001 Device 057: ID 1a40:0101 Terminus Technology Inc. Hub
	Bus 001 Device 093: ID 1d50:6017 OpenMoko, Inc. Black Magic Debug Probe (DFU)
	Bus 001 Device 002: ID 2109:3431 VIA Labs, Inc. Hub
	Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	
With the DFU bootloader running,  we download the blackmagic firmware using DFU.

	koen@raspberrypi:~/src/blackmagic/src $ ~/.arduino15/packages/STM32/tools/STM32Tools/1.3.2/tools/linux/dfu-util/dfu-util -d 1d50:6018,:6017 -s 0x08002000:leave -D blackmagic.bin
	dfu-util 0.9
	
	Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
	Copyright 2010-2016 Tormod Volden and Stefan Schmidt
	This program is Free Software and has ABSOLUTELY NO WARRANTY
	Please report bugs to http://sourceforge.net/p/dfu-util/tickets/
	
	dfu-util: Invalid DFU suffix signature
	dfu-util: A valid DFU suffix will be required in a future dfu-util release!!!
	Opening DFU capable USB device...
	ID 1d50:6017
	Run-time device DFU version 011a
	Claiming USB DFU Interface...
	Setting Alternate Setting #0 ...
	Determining device status: state = dfuIDLE, status = 0
	dfuIDLE, continuing
	DFU mode device DFU version 011a
	Device returned transfer size 1024
	DfuSe interface name: "Internal Flash   "
	Downloading to address = 0x08002000, size = 85068
	Download	[=========================] 100%        85068 bytes
	Download done.
	File downloaded successfully
	Transitioning to dfuMANIFEST state
	koen@raspberrypi:~/src/blackmagic/src $ lsusb
	Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
	Bus 001 Device 080: ID 1a86:7523 QinHeng Electronics HL-340 USB-Serial adapter
	Bus 001 Device 060: ID 0482:0011 Kyocera Corp. 
	Bus 001 Device 059: ID 04d9:1818 Holtek Semiconductor, Inc. Keyboard [Diatec Filco Majestouch 2]
	Bus 001 Device 058: ID 046d:c05a Logitech, Inc. M90/M100 Optical Mouse
	Bus 001 Device 057: ID 1a40:0101 Terminus Technology Inc. Hub
	Bus 001 Device 094: ID 1d50:6018 OpenMoko, Inc. Black Magic Debug Probe (Application)
	Bus 001 Device 002: ID 2109:3431 VIA Labs, Inc. Hub
	Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	koen@raspberrypi:~ $ ls -l /dev/ttyBmp*
	lrwxrwxrwx 1 root root 7 Mar  9 19:53 /dev/ttyBmpGdb -> ttyACM0
	lrwxrwxrwx 1 root root 7 Mar  9 19:53 /dev/ttyBmpTarg -> ttyACM1

If the two /dev/ttyBmp* devices do not show up, check you installed ``/etc/udev/rules.d/99-blackmagic.rules``.

## Connecting to target

As target system we use another Blue Pill. Connect BMP and target like this:

Black Magic Probe  | Target  | Comment
--- | --- | ---
GND | GND |
PB14 | SWDIO |
PA5 | SWCLK |
PA3 | RXD | Optional
PA2 | TXD | Optional
3V3 | 3V3 | Careful! Only connect one power source.

Connect the Black Magic Probe USB to the Raspberry.  Now we are ready to connect to the target system. 
	
	koen@raspberrypi:~/src/blackmagic/src $ ~/.arduino15/packages/STM32/tools/xpack-arm-none-eabi-gcc/9.2.1-1.1/bin/arm-none-eabi-gdb -ex "target extended-remote /dev/ttyBmpGdb"
	GNU gdb (xPack GNU Arm Embedded GCC, 32-bit) 8.3.0.20190709-git
	Copyright (C) 2019 Free Software Foundation, Inc.
	License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
	This is free software: you are free to change and redistribute it.
	There is NO WARRANTY, to the extent permitted by law.
	Type "show copying" and "show warranty" for details.
	This GDB was configured as "--host=armv8l-unknown-linux-gnueabihf --target=arm-none-eabi".
	Type "show configuration" for configuration details.
	For bug reporting instructions, please see:
	<http://www.gnu.org/software/gdb/bugs/>.
	Find the GDB manual and other documentation resources online at:
	    <http://www.gnu.org/software/gdb/documentation/>.
	
	For help, type "help".
	Type "apropos word" to search for commands related to "word".
	Remote debugging using /dev/ttyBmpGdb
	(gdb) monitor swdp
	Target voltage: unknown
	Available Targets:
	No. Att Driver
	 1      STM32F1 medium density M3/M4
	(gdb) 


not truncated	