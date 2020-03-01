# stm32duino-raspberrypi

A build of an arduino toolchain that runs on raspberry pi and targets stm32 arm processors ("blue pill").

## Installation

Start and exit the Arduino IDE. This creates the directory ``~/.arduino15``  in your home directory, and the file ``~/.arduino15/preferences.txt``

Edit ``.arduino15/preferences.txt``, and add the following line:
```
allow_insecure_packages=true
```
This allows the use of unsigned packages.

Start  the Arduino IDE. In *File --> Preferences --> Additional Board Manager URLs:* paste the following url:
```
https://raw.githubusercontent.com/koendv/stm32duino-raspberrypi/master/BoardManagerFiles/package_stm_index.json
```
Press OK.

Open *Tools -> Board: -> Boards Manager*
In the search field, type "STM32". Install the "STM32 Cores" board package, version 1.8.0. You may get a message *[exec] Warning: forced trusting untrusted contributions*. Press close.

The STM32 cores are at the very bottom of the list of supported boards. 
As an example, if using a STM32F103 Blue Pill choose *Tools->Board: -> Generic STM32F1 series* .

## Usage
Under *Tools->Upload Method* you'll find a number of tools to upload firmware.  

| Menu  | command  |
|---|---|
|STM32CubeProgrammer (SWD) | st-flash
|STM32CubeProgrammer (Serial) | stm32flash
|STM32CubeProgrammer (DFU) | dfu-util
|HID Bootloader | hid-flash

## Build notes
To build the tools:
```
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
These last two commands need to be repeated every time you modify the sources. If you have not modified the sources since the last run, ``ant run`` is sufficient.


not truncated.