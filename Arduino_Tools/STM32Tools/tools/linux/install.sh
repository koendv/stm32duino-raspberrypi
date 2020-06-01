#!/bin/sh

if sudo [ -w /etc/udev/rules.d ]; then
    echo "Copying udev rules..."
    for RULE in 45-maple.rules 49-stlinkv1.rules 49-stlinkv2-1.rules 49-stlinkv2.rules 49-stlinkv3.rules 49-stm32_hid_bl.rules 99-blackmagic.rules
    do
      sudo cp -v $RULE /etc/udev/rules.d/
      sudo chown root:root /etc/udev/rules.d/$RULE
      sudo chmod 644 /etc/udev/rules.d/$RULE
    done
    echo "Reloading udev rules"
    sudo udevadm control --reload-rules
    echo "Adding current user to dialout group"
    sudo adduser $USER dialout
else
    echo "Couldn't copy rules to /etc/udev/rules.d/; you probably have to run this script as root?"
fi

