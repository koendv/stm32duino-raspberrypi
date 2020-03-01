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

case "$PROTOCOL" in
"10")
	# stlink with erase
	$(dirname $0)/st-flash erase
	;&
"0")
	# stlink
	$(dirname $0)/st-flash write ${FILEPATH} 0x8000000
	;;
"11")
	# serial upload with erase
	$(dirname $0)/stm32flash -o /dev/"$3" 
	;&
"1")
	# serial upload
	$(dirname $0)/stm32flash -g 0x8000000 -b 115200 -w ${FILEPATH} /dev/"$3" 
	;;
"12"|"2")
	# dfu - someone fix this
	$(dirname $0)/dfu-util/dfu-util -D ${FILEPATH} -d 1eaf:0003 --intf 0 --alt 1
	;;
*)
	echo "$0: Please update this script."
	;;
esac
#not truncated
