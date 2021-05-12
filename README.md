# stm32duino-raspberrypi

_This software is for arduino IDE v1. I am migrating to [arduino-ide v2](https://github.com/koendv/arduino-ide-raspberrypi), also on raspberry._

This is software for Raspberry Pi that allows you to develop Arduino sketches for STM32 arm boards (Blue Pill).

## Installation
By itself, the [Arduino IDE](https://www.arduino.cc/en/Main/Software) does not support STM32 arm processors. This software for arm linux adds support for STM32 arm processors to the Arduino IDE.

Start and exit the Arduino IDE. This creates the directory `~/.arduino15`  in your home directory, and the file `~/.arduino15/preferences.txt`.

With the Arduino IDE **not** running, edit `.arduino15/preferences.txt`, and add the following line:
```
allow_insecure_packages=true
```
This allows the use of unsigned packages like this one. Also tick "Verbose output during upload".

Start  the Arduino IDE. In *File --> Preferences --> Additional Board Manager URLs:* paste the following url:
```
https://raw.githubusercontent.com/koendv/stm32duino-raspberrypi/master/BoardManagerFiles/package_stm_index.json
```
Press OK.

Open *Tools -> Board: -> Boards Manager*
In the search field, type "STM32". Install the "STM32 Cores" board package. Instalation takes about 6 minutes. Press close. Ignore any messages "Warning: forced trusting untrusted contributions".

In the Tools menu select the STM32 cores as compilation target. As an example, if using a STM32F103 Blue Pill choose *Tools->Board: -> Generic STM32F1 series* .

The tools to upload firmware are installed in the tools directory, `~/.arduino15/packages/STM32/tools/STM32Tools/1.4.0/tools/linux`.

Run the shell script `install.sh` in the tools directory to install udev rules and add the current user to the `dialout` group.

If needed, edit the shell script `stm32CubeProg.sh` in the tools directory to change the command line options of the STM32CubeProgrammer firmware upload commands.

If you need to [pass flags directly to the compiler](https://github.com/stm32duino/wiki/wiki/Customize-build-options-using-build_opt.h), create a file `build_opt.h` with the compiler and linker flags.

## Description

Under *Tools->Upload Method* you'll find a number of options to upload firmware.

| Menu  | Command executed  |
|---|---|
|STM32CubeProgrammer (SWD) | st-flash
|STM32CubeProgrammer (Serial) | stm32flash
|STM32CubeProgrammer (DFU) | dfu-util
|Black Magic Probe | arm-none-eabi-gdb
|HID Bootloader | hid-flash
|Maple DFU Uploader | maple_upload

First the boot jumpers are described, then the upload methods.

### Boot jumpers

The STM32 has rom, flash and ram. Two pins, `Boot0` and `Boot1`, determine whether the processor boots from rom, flash or ram. On a Blue Pill, the value of `Boot0` and `Boot1` is determined by two jumpers.

Boot1 | Boot0 | Mode | Address
--- | --- | --- | ---
x | 0 | Boot from flash | 0x0800 0000
0 | 1| Boot from  rom |
1 | 1| Boot from ram | 0x2000 0000

These jumper settings take effect next time you boot, whether it is by pushing reset, by power cycling, or when the processor exits the standby (sleep) mode.

The rom contains a factory-programmed bootloader.  After booting from rom, you can upload firmware either over the serial port, over USB, over I2C, ... Exactly what ports can be used to upload firmware depends upon the STM32 processor model. The STM32F103C8T6 rom only supports upload over the serial port.

> Even if your firmware hangs, you can always change jumper settings, boot from rom, upload new firmware, and change the jumpers back to booting from flash.

The authoritative guide how to activate the bootloader and what ports can be used is STM Application note [AN2606:  STM32 microcontroller system memory boot mode](https://www.st.com/content/ccc/resource/technical/document/application_note/b9/9b/16/3a/12/1e/40/0c/CD00167594.pdf/files/CD00167594.pdf/jcr:content/translations/en.CD00167594.pdf).

### Serial Wire Debugging (SWD)

Serial Wire Debugging uses two STM32 pins, `SWCLK` (`PA14`) and `SWDIO` (`PA13`). Connect raspberry and Blue Pill using a st-link adapter.

Set boot Jumpers to boot from flash: `Boot0`=0, `Boot1`=0. Push reset.

Connections:

st-link | Blue Pill |  Comment
--- | --- | ---
`GND` | `GND` |
`SWCLK` | `SWCLK` |
`SWDIO` | `SWIO` |
`3.3V` | `3v3` | Careful! Connect only one power supply.
`RST` | `R` | Optional. Only if "reset" command needed

Connecting the reset pin is only needed if you use the ``st-flash reset`` command.

> Connect only one power supply at a time. Connect a Blue pill to 5V using the USB connector, or connect to 3.3V using the st-link. Do not connect both at the same time, you risk damaging the device.

In the Arduino IDE choose *Tools->Upload Method -> STM32CubeProgrammer (SWD)* and then *Sketch->Upload*. Or from the command line:
```
st-flash write Blink.bin 0x8000000
```
where Blink.bin is the firmware, and 0x8000000 is the start address of flash memory.

### Serial Port

Set boot Jumpers to boot from rom: `Boot0`=1, `Boot1`=0. Push reset. This activates the rom bootloader.

Connections:

USB-serial adapter | Blue Pill | Comment
--- | --- | ---
`GND` | `GND`
`RX` | `A9/TX1`
`TX` | `A10/RX1`
`5V` | `5V` | Careful! Connect only one power supply.

In the Arduino IDE choose *Tools->Upload Method -> STM32CubeProgrammer (Serial)* and then *Sketch->Upload*. Or from the command line:

```
stm32flash -g 0x8000000 -b 115200 -w Blink.bin /dev/ttyUSB0
```
Your sketch starts running automatically after upload. Push reset before compiling again.

Once you're done compiling, set boot Jumper settings back to boot from flash: `Boot0`=0, `Boot1`=0.

If you have a problem, a simple loopback test checks whether the USB-serial adapter works. Connect the `TX` and `RX` pins of the USB-serial adapter with jumper wire. Connect to the serial port using `gtkterm` or `minicom`. Type a few characters; observe the `TX` *and* `RX` leds blink, and the characters gets echoed on the screen.

### Device Firmware Update (DFU)

Device Firmware Update allows uploading firmware over USB. A device like the STM32F401 has a built-in USB port, and you can just boot from rom, and use `dfu-util` to upload your firmware over USB. A device like the STM32F103C8T6 also has a built-in USB port, but the rom bootloader of the STM32F103C8T6 is serial port only and does not support DFU.

There is a workaround, a software DFU implementation for devices where the bootloader rom does not support DFU. This bootloader uses 8K flash on a Blue Pill. USB ID 1eaf:0004 and 1eaf:0003.

Download bootloader firmware from [STM32duino-bootloader](https://github.com/rogerclarkmelbourne/STM32duino-bootloader)

Installation:

	$ stm32flash -w generic_boot20_pc13.bin /dev/ttyUSB0
	$ lsusb
	...
	Bus 001 Device 040: ID 1eaf:0003
	$ dfu-util -l
	dfu-util 0.9
	
	Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
	Copyright 2010-2016 Tormod Volden and Stefan Schmidt
	This program is Free Software and has ABSOLUTELY NO WARRANTY
	Please report bugs to http://sourceforge.net/p/dfu-util/tickets/
	
	Found DFU: [1eaf:0003] ver=0201, devnum=49, cfg=1, intf=0, path="1-1.4.4", alt=2, name="STM32duino bootloader v1.0  Upload to Flash 0x8002000", serial="LLM 003"
	Found DFU: [1eaf:0003] ver=0201, devnum=49, cfg=1, intf=0, path="1-1.4.4", alt=1, name="STM32duino bootloader v1.0  Upload to Flash 0x8005000", serial="LLM 003"
	Found DFU: [1eaf:0003] ver=0201, devnum=49, cfg=1, intf=0, path="1-1.4.4", alt=0, name="STM32duino bootloader v1.0  ERROR. Upload to RAM not supported.", serial="LLM 003"
	
After power-up, the Blue Pill stays in the bootloader if jumpers set as follows: `Boot0`=0, `Boot1`=1.

If loading the Sketch firmware at 0x8002000, one also has to link the firmware at  0x8002000.

### Black Magic Probe
Black Magic firmware turns a Blue Pill into a gdb server.
To use the Black Magic Probe, you need two Blue Pills. One Blue Pill is the debugger probe and runs the Black Magic Probe firmware; the other Blue Pill is the target system and runs your Arduino sketch. The  Black Magic Probe (BMP) is connected to the Raspberry over USB. The target system is connected to the Black Magic Probe (BMP) over Serial Wire Debugging (SWD). The probe can be used to upload firmware, set breakpoints, inspect variables, etc.  Select *Tools->Optimize->Debug (-g)*, else `gdb` may not know names of variables and functions, or line numbers (no symbol table). 

This document explains how to [convert an STM32F103 Blue Pill to a Black Magic Probe](https://github.com/koendv/stm32duino-raspberrypi/blob/master/blackmagic.md).

You need to [patch platform.txt](https://raw.githubusercontent.com/koendv/stm32duino-raspberrypi/master/Arduino_Tools/patch/STM32-1.8.0-platform.txt.patch) for Black Magic Probe to work on STM Core 1.8.0.

For information see the  [Black Magic Probe Wiki](https://github.com/blacksphere/blackmagic/wiki)
  
### HID Bootloader
No special USB driver needed. The HID bootloader uses 2K flash on a Blue Pill. USB ID 1209:beba. Download bootloader firmware from [Serasidis](https://github.com/Serasidis/STM32_HID_Bootloader)

Installation:

	$ stm32flash -w ./stm32_binaries/F103/low_and_medium_density/hid_generic_pc13.bin /dev/ttyUSB0
	$ lsusb
	...
	Bus 001 Device 012: ID 1209:beba Generic serasidis.gr STM32 HID Bootloader

After power-up, the Blue Pill  stays in the bootloader if jumpers are as follows: `Boot0`=0, `Boot1`=1.
In the Arduino IDE choose *Tools->Upload Method->HID Bootloader 2.2*.

### Maple DFU Uploader

Both "Tools->Upload Method->Device Firmware Update (DFU)" and "Tools->Upload Method->Maple DFU uploader" upload using the DFU protocol. The difference is how to get the device into the DFU bootloader:

* on "Device Firmware Update (DFU)" devices, setting jumper switches and pushing the reset button boots the device in DFU mode.
* on "Maple DFU uploader" devices, a command-line tool `upload-reset`boots the device in DFU mode.

This corresponds to hardware differences: different electronics to reset the USB port.

### OpenOCD

If you have a Raspberry Pi, you do not need an st-link to download firmware to a Blue Pill over Serial Wire Debugging (SWD). Connect the Blue Pill directly to the Raspberry GPIO pins, and then download using [openocd](http://www.openocd.org).

To install openocd, enter:
```
sudo apt-get install openocd
```
Set boot Jumpers to boot from flash: `Boot0`=0, `Boot1`=0.

Connections:

| Raspberry GPIO | Blue Pill | Comment |
| --- | --- | --- |
| `GND` | `GND` | |
| `GPIO24` | `SWDIO` ||
| `GPIO25` | `SWCLK` ||
| `GPIO18` | `RST` | Optional |
| `3.3V` | `3V3` | Careful! Connect only one power supply. |

To learn more about using openocd, see [Programming Microcontrollers using OpenOCD on a Raspberry Pi](https://learn.adafruit.com/programming-microcontrollers-using-openocd-on-raspberry-pi/overview)

## Build notes

To build the tools:
```
apt-get update
apt-get install build-essential git libusb-1.0-0-dev autotools-dev autoconf automake cmake pkg-config
git clone https://github.com/koendv/stm32duino-raspberrypi
cd stm32duino-raspberrypi/Arduino_Tools/
sh ./build.sh
ls -l STM32Tools-*
```
`st-flash` is patched for static linking with `libstlink.a` . This avoids library version conflicts if stm32duino and `/usr/bin/` have different versions of `st-flash`.

The release binaries are built for arm linux (32 and 64 bit) and intel linux (32 and 64 bit) at [opensuse build service](https://build.opensuse.org/package/show/home:koendv/stm32duino-raspberrypi).

Sometimes you need the latest version of the Arduino IDE. To build the Arduino IDE from source:
```
sudo apt-get install git make gcc ant openjdk-8-jdk unzip openjfx
git clone https://github.com/arduino/Arduino.git
cd Arduino
cd Arduino/build
ant dist
ant run
```
The commands ``ant dist; ant run`` need to be repeated every time you modify the IDE sources. If you have not modified the IDE sources since the last run, ``ant run`` is sufficient.

_not truncated._

