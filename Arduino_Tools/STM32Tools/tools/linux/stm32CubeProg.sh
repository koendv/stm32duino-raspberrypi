#!/bin/bash
# parameters:
# stm32CubeProg.sh {upload.protocol} "{build.path}/{build.project_name}.bin" {upload.options}
# protocol:
# 0 swd
# 1 serial
# 2 dfu
#


PROTOCOL=$1
FILEPATH=$2
TOOLDIR=$(dirname $0)

case "$PROTOCOL" in
"10")
	# stlink with erase
	$TOOLDIR/st-flash erase
	;&
"0")
	# stlink
	$TOOLDIR/st-flash write ${FILEPATH} 0x8000000
	;;
"11")
	# serial upload with erase
	$TOOLDIR/stm32flash -o /dev/"$3"
	;&
"1")
	# serial upload
	if [[ $# -lt 4 ]]; then
		echo "Please select serial port"
	fi
	$TOOLDIR/stm32flash -g 0x8000000 -b 115200 -w ${FILEPATH} /dev/"$3"
	;;
"12"|"2")
	# dfu
	# $TOOLDIR/dfu-util/dfu-util -D ${FILEPATH} -d 1eaf:0003 --intf 0 --alt 1
	$TOOLDIR/dfu-util/dfu-util -D ${FILEPATH}
	;;
*)
	echo "$0: Please update this script."
	;;
esac
#not truncated
