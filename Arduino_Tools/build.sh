#!/bin/bash

VERSION=1.4.0
TOPDIR=$PWD
TOOLDIR=$PWD/STM32Tools/tools/linux
SRCDIR=$PWD/src

install -d $TOOLDIR $TOOLDIR/dfu-util

cd $SRCDIR

cd dfu-util
sh ./autogen.sh
./configure
make
install src/dfu-util $TOOLDIR/dfu-util/
install src/dfu-prefix $TOOLDIR/dfu-util/
install src/dfu-suffix $TOOLDIR/dfu-util/
#make clean
cd $SRCDIR

cd hid-flash/cli/
make
install hid-flash $TOOLDIR
#make clean
cd $SRCDIR

cd stlink
mkdir build
cd build
cmake ..
make
install bin/st-flash $TOOLDIR
install bin/st-info $TOOLDIR
install bin/st-util $TOOLDIR
#make clean
cd $SRCDIR

cd stm32flash
make
install stm32flash $TOOLDIR
cd $SRCDIR

cd upload-reset
gcc -o upload-reset upload-reset.c
install upload-reset $TOOLDIR
cd $SRCDIR

cd $TOPDIR
tar cf STM32Tools-$VERSION-linux.tar STM32Tools
rm -f STM32Tools-$VERSION-linux.tar.bz2
bzip2 --best STM32Tools-$VERSION-linux.tar

#not truncated
