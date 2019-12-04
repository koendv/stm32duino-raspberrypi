# stm32duino-raspberrypi

This is a build of an arduino toolchain that runs on raspberry pi and targets stm32 arm processors ("blue pill").

## arm-none-eabi toolchain
Download gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2 from
https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads

```
apt-get -f install -y build-essential autoconf autogen bison dejagnu flex flip gawk git gperf gzip nsis openssh-client p7zip-full perl python-dev libisl-dev scons tcl texinfo tofrodos wget zip texlive texlive-extra-utils libncurses5-dev

mkdir ~/toolchain
cd toolchain/
mv ../gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2 .
tar -xjf gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2
cd ./gcc-arm-none-eabi-9-2019-q4-major
./install-sources.sh 
cd ../

In "build-common.sh" replace JOBS=`grep ^processor /proc/cpuinfo|wc -l` with JOBS=1

./build-prerequisites.sh --skip_steps=mingw32
./build-toolchain.sh --build_type=native --skip_steps=mingw32,mingw32-gdb-with-python,manual
```
## STM32Tools

Download STM32Tools-1.3.1-linux.tar.bz2 
Download STM32_HID_Bootloader-2.2.2.tar.gz from https://github.com/Serasidis/STM32_HID_Bootloader/releases
```
tar xvf ~/Downloads/STM32Tools-1.3.1-linux.tar.bz2

cd STM32Tools/tools/
rm -rf linux64

cd src/dfu-util
sh ./autogen.sh
./configure
make
install src/dfu-util ../../linux/dfu-util/
install src/dfu-prefix ../../linux/dfu-util/
install src/dfu-suffix ../../linux/dfu-util/
make clean

cd ../massStorageCopy/
make massStorageCopy
install massStorageCopy ../../linux/
make clean

cd ../upload-reset/
gcc -o upload-reset upload-reset.c
mv upload-reset ../../linux/
cd ..
```

Build the hid-flash utility:

```
tar xvf ~/Downloads/STM32_HID_Bootloader-2.2.2.tar.gz 
cd STM32_HID_Bootloader-2.2.2/cli/
make
install hid-flash ../../../linux/
make clean
```
Package everything in a tar archive:
```
cd ../../../../../

tar cvf STM32Tools-1.3.1-raspberrypi.tar ./STM32Tools
bzip2 --best STM32Tools-1.3.1-raspberrypi.tar
```
not truncated