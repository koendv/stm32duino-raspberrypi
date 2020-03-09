# stm32duino-raspberrypi

An arduino toolchain that runs on raspberry pi and targets stm32 arm processors ("blue pill").

## Installation

Start and exit the Arduino IDE. This creates the directory ``~/.arduino15``  in your home directory, and the file ``~/.arduino15/preferences.txt``

With the Arduino IDE not running, edit ``.arduino15/preferences.txt``, and add the following line:
```
allow_insecure_packages=true
```
This allows the use of unsigned packages like this one. Also tick *Verbose output during upload*.

Start  the Arduino IDE. In *File --> Preferences --> Additional Board Manager URLs:* paste the following url:
```
https://raw.githubusercontent.com/koendv/stm32duino-raspberrypi/master/BoardManagerFiles/package_stm_index.json
```
Press OK.

Open *Tools -> Board: -> Boards Manager*
In the search field, type "STM32". Install the "STM32 Cores" board package, version 1.8.0. Instalation takes about 6 minutes. Press close. Ignore any messages *Warning: forced trusting untrusted contributions*.

In the Tools menu select the STM32 cores as compilation target.
As an example, if using a STM32F103 Blue Pill choose *Tools->Board: -> Generic STM32F1 series* .

The tools to upload firmware are installed in the tools directory, ``~/.arduino15/packages/STM32/tools/STM32Tools/1.3.2/tools/linux``.

Run the shell script ``install.sh`` in the tools directory to install udev rules and add the current user to the dialout group.

If needed, edit the shell script ``stm32CubeProg.sh`` in the tools directory to change the command line options of the STM32CubeProgrammer firmware upload commands.

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

First the boot jumpers are described, then the upload method are described.

### Boot jumpers

The STM32 has rom, flash and ram. Two pins, Boot0 and Boot1, determine whether the processor boots from rom, flash or ram. On a Blue Pill, the value of Boot0 and Boot1 is determined by two jumpers.

Boot1 | Boot0 | Mode | Address
--- | --- | --- | ---
x | 0 | Boot from flash | 0x0800 0000
0 | 1| Boot from  rom |
1 | 1| Boot from ram | 0x2000 0000

These jumper settings take effect next time you boot, whether it is by pushing reset, or by power cycling, or when the processor exits the standby (sleep) mode.

The rom contains a factory-programmed bootloader.  After booting from rom, you can upload firmware either over the serial port, over USB, over I2C, ... Exactly what ports can be used to upload firmware depends upon the STM32 processor model. The STM32F103C8T6 rom only supports upload over the serial port. 

> Even if your firmware hangs, you can always change jumper settings, boot from rom, upload new firmware, and change the jumpers back to booting from flash.

The authoritative guide how to activate the bootloader and what ports can be used is STM Application note [AN2606:  STM32 microcontroller system memory boot mode](https://www.st.com/content/ccc/resource/technical/document/application_note/b9/9b/16/3a/12/1e/40/0c/CD00167594.pdf/files/CD00167594.pdf/jcr:content/translations/en.CD00167594.pdf).

### Serial Wire Debugging (SWD)

Serial Wire Debugging uses two STM32 pins, SWCLK (PA14) and SWDIO (PA13). Connect raspberry and Blue Pill using a st-link adapter.

Set boot Jumper settings: Boot0=0, Boot1=0. (boot from flash). Push reset.

Connections:

st-link | Blue Pill |  Comment
--- | --- | ---
SWCLK | SWCLK |
SWDIO | SWIO |
GND | GND |
3.3V | 3v3 | Careful! Connect only one power supply.
RST | R | Optional. Only if "reset" command needed

Connecting the reset pin is only needed if you use the ``st-flash reset`` command.

> Connect only one power supply at a time. Connect a Blue pill to 5V using the USB connector, or connect to 3.3V using the st-link. Do not connect both at the same time, you risk damaging a chip.

In the Arduino IDE choose *Tools->Upload Method -> STM32CubeProgrammer (SWD)* and then *Sketch->Upload*. Or from the command line:
```
st-flash write Blink.bin 0x8000000
```
where Blink.bin is the firmware, and 0x8000000 is the start address of flash memory.

### Serial Port

Set boot Jumper settings: Boot0=1, Boot1=0 (boot from rom). Push reset. This activates the rom bootloader.

Connections:

USB-serial adapter | Blue Pill | Comment
--- | --- | ---
RX | A9 TX1
TX | A10 RX1
GND | GND
5V | 5V | Careful! Connect only one power supply.

In the Arduino IDE choose *Tools->Upload Method -> STM32CubeProgrammer (Serial)* and then *Sketch->Upload*. Or from the command line:

```
stm32flash -g 0x8000000 -b 115200 -w Blink.bin /dev/ttyUSB0
```
Your sketch starts running automatically after upload. Push reset before compiling again.

Once you're done compiling, set boot Jumper settings: Boot0=0, Boot1=0. (boot from flash).

If you have a problem, a simple loopback test checks whether the USB-serial adapter works. Connect the TX and RX pins of the USB-serial adapter with jumper wire. Connect to the serial port using gtkterm or minicom. Type a few characters; observe the TX *and* RX leds blink, and the characters gets echoed on the screen.

### Device Firmware Update (DFU)

Device Firmware Update allows uploading firmware over USB. In many STM32 devices with a built-in USB port, you can just boot from rom, and use dfu-util to upload your firmware over USB. However, the rom bootloader of the STM32F103C8T6 is serial port only and does not support DFU.

### Black Magic Probe
Black Magic firmware turns a Blue Pill into a gdb server. 
To use the Black Magic Probe, you need two Blue Pills. One Blue Pill is the debugger probe and runs the Black Magic firmware; the other Blue Pill is the target system and runs your Arduino sketch. The debugger probe is connected to the Raspberry over USB and to the target system over Serial Wire Debugging (SWD). Apart from uploading firmware, also allows setting breakpoints, inspecting variables, etc.

See also: [Converting an STM32F103 Blue Pill to a Black Magic Probe](https://github.com/koendv/stm32duino-raspberrypi/blob/master/blackmagic.md).

 [Source](https://github.com/blacksphere/blackmagic/wiki) 

### HID Bootloader
No special USB driver needed. Uses 2K flash on a Blue Pill. USB ID 1209:beba.  [Source](https://github.com/Serasidis/STM32_HID_Bootloader)

### Maple DFU Uploader
Software DFU implementation for devices where the bootloader rom does not support DFU. Uses 8K flash on a Blue Pill. USB ID 1eaf:0004 and 1eaf:0003. [Source](https://github.com/rogerclarkmelbourne/Arduino_STM32/wiki)

### OpenOCD

If you have a Raspberry Pi, you do not need an st-link to download firmware to a Blue Pill over Serial Wire Debugging (SWD). Connect the Blue Pill directly to the Raspberry GPIO pins, and then download using [openocd](http://www.openocd.org).

To install openocd, enter:
```
sudo apt-get install openocd
```
Boot Jumper settings: Boot0=0, Boot1=0 (boot from flash).

Connections:

| Raspberry GPIO | Blue Pill | Comment |
| --- | --- | --- |
| GND | GND | |
| GPIO 24 | SWDIO ||
| GPIO 25 | SWCLK ||
| GPIO 18 | RST | Optional |
| 3.3V | 3V3 | Careful! Connect only one power supply. |

To learn more about using openocd, see [Programming Microcontrollers using OpenOCD on a Raspberry Pi](https://learn.adafruit.com/programming-microcontrollers-using-openocd-on-raspberry-pi/overview)

## Build notes
To build the tools:
```
apt-get update
apt-get install build-essential git libusb-1.0-0-dev autotools-dev autoconf automake cmake
git clone https://github.com/koendv/stm32duino-raspberrypi
cd stm32duino-raspberrypi/Arduino_Tools/
sh ./build.sh
ls -l STM32Tools-*
```
st-flash is patched for static linking with libstlink.a . This avoids library version conflicts if stm32duino and /usr/bin/ have different versions of st-flash.

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
