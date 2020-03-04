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
In the search field, type "STM32". Install the "STM32 Cores" board package, version 1.8.0. Installing takes about 6 minutes. Press close. Ignore any messages *Warning: forced trusting untrusted contributions*.

In the Tools menu select the STM32 cores as compilation target.
As an example, if using a STM32F103 Blue Pill choose *Tools->Board: -> Generic STM32F1 series* .

## Usage
Under *Tools->Upload Method* you'll find a number of tools to upload firmware. 

| Menu  | Command  |
|---|---|
|STM32CubeProgrammer (SWD) | st-flash
|STM32CubeProgrammer (Serial) | stm32flash
|STM32CubeProgrammer (DFU) | dfu-util
|Black Magic Probe | arm-none-eabi-gdb
|HID Bootloader | hid-flash
|Maple DFU Uploader | maple_upload

The tools to upload firmware are installed in ``~/.arduino15/packages/STM32/tools/STM32Tools/1.3.2/tools/linux``. 

Run the shell script ``install.sh`` in the tools directory to install udev rules and add the current user to the dialout group. 

Edit the shell script ``stm32CubeProg.sh`` to change the command line options of the STM32CubeProgrammer firmware upload commands.

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

Sometimes you need the latest version of the IDE. To build the Arduino IDE from source:
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
