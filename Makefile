#
# Makefile for opensuse build service
# https://build.opensuse.org/package/show/home:koendv/stm32duino-raspberrypi
#
build:
	pwd; cd Arduino_Tools; sh ./build.sh

clean:

install:
	mkdir -p ${DESTDIR}/usr/share; install Arduino_Tools/STM32Tools-1.3.2-linux.tar.bz2 ${DESTDIR}/usr/share
