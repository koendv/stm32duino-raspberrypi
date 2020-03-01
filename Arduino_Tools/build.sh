#!/bin/bash

TOOLDIR=$PWD/linux
SRCDIR=$PWD/src
install -d $TOOLDIR $TOOLDIR/dfu-util

cd dfu-util
sh ./autogen.sh
./configure
make
install -D src/dfu-util $TOOLDIR/dfu-util/
install -D src/dfu-prefix $TOOLDIR/dfu-util/
install -D src/dfu-suffix $TOOLDIR/dfu-util/
#make clean
cd $SRCDIR

cd hid-flash/cli/
make
install -D hid-flash $TOOLDIR
#make clean
cd $SRCDIR

cd stlink
make
install -D build/Release/st-flash $TOOLDIR
install -D build/Release/st-info $TOOLDIR
#make clean
cd $SRCDIR

cd stm32flash
make
install -D stm32flash $TOOLDIR
cd $SRCDIR

#not truncated
