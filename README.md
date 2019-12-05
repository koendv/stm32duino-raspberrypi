# stm32duino-raspberrypi

This is a build of an arduino toolchain that runs on raspberry pi and targets stm32 arm processors ("blue pill").

In stm32 platform.txt change 
```
-compiler.path={runtime.tools.arm-none-eabi-gcc-8.3.1-1.3.path}/bin/
+compiler.path={runtime.tools.arm-none-eabi-gcc-9.2.1.path}/bin/
```
# Build notes
## arm-none-eabi toolchain
Download gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2 from
https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads

```
apt-get -f install -y build-essential autoconf autogen bison dejagnu flex flip gawk git gperf gzip nsis openssh-client p7zip-full perl python-dev libisl-dev scons tcl texinfo tofrodos wget zip texlive texlive-plain-generic texlive-extra-utils libncurses5-dev

mkdir ~/toolchain
cd toolchain/
mv ../gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2 .
tar -xjf gcc-arm-none-eabi-9-2019-q4-major-src.tar.bz2
cd ./gcc-arm-none-eabi-9-2019-q4-major
./install-sources.sh 
```
In "build-common.sh" replace JOBS=`grep ^processor /proc/cpuinfo|wc -l` with JOBS=1, to avoid running out of memory.
```
--- build-common.sh.ORIG	2019-12-05 11:42:34.735262457 +0100
+++ build-common.sh	2019-12-05 11:42:10.175711531 +0100
@@ -304,7 +304,8 @@
     BUILD="$host_arch"-linux-gnu
     HOST_NATIVE="$host_arch"-linux-gnu
     READLINK=readlink
-    JOBS=`grep ^processor /proc/cpuinfo|wc -l`
+    #JOBS=`grep ^processor /proc/cpuinfo|wc -l`
+    JOBS=1
     GCC_CONFIG_OPTS_LCPP="--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm"
     MD5="md5sum -b"
     PACKAGE_NAME_SUFFIX="${host_arch}-linux"
```
Begin build:
```
./build-prerequisites.sh --skip_steps=mingw32
./build-toolchain.sh --build_type=native --skip_steps=mingw32,mingw32-gdb-with-python,howto,manual
```
The build takes about 16.5 hours.

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

tar cvf STM32Tools-1.3.1-armv7l-linux-gnu.tar ./STM32Tools
bzip2 --best STM32Tools-1.3.1-armv7l-linux-gnu.tar
```
not truncated
