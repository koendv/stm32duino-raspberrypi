#!/bin/bash
# parameters:
# stm32CubeProg.sh {upload.protocol} "{build.path}/{build.project_name}.bin" {upload.options}
# protocol:
# 0 swd
# 1 serial
# 2 dfu
#

PROTOCOL=$1
OBJECT=$2

case "$PROTOCOL" in
"0")
	# stlink
	$(dirname $0)/st-flash write ${OBJECT} 0x8000000
	;;
"1")
	# serial upload
	$(dirname $0)/stm32flash -g 0x8000000 -b 115200 -w ${OBJECT} /dev/"$4" 
	;;
"2")
	# dfu - someone with a maple fix this
	$(dirname $0)/dfu-util -D ${OBJECT} -d 1eaf:0003 --intf 0 --alt 1
	;;
*)
	echo "Please update this script."
	;;
esac
#not truncated
