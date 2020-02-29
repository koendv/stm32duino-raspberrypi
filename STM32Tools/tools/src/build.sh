#!/bin/bash

TOOLDIR=$PWD/../linux
TOPDIR=$PWD
install -d $TOOLDIR

cd dfu-util
sh ./autogen.sh
./configure
make
install -D src/dfu-util $TOOLDIR
#make clean
cd $TOPDIR

cd STM32_HID_Bootloader/cli/
make
install -D hid-flash $TOOLDIR
#make clean
cd $TOPDIR

cd stlink
make
install -D build/Release/st-flash $TOOLDIR
install -D build/Release/st-info $TOOLDIR
#make clean
cd $TOPDIR

cd stm32flash-serial
make
install -D stm32flash $TOOLDIR
cd $TOPDIR

#not truncated
