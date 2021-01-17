#!/bin/sh

NEW_RPI="$1"

cat basic.sh | ssh pi@$NEW_RPI

# change hostname
ssh pi@$NEW_RPI "sudo bash -c 'hostname $NEW_RPI; echo $NEW_RPI > /etc/hostname'"

ssh pi@$NEW_RPI 'bash -c "[ -d rpi-scripts ] || git clone https://github.com/lhost/rpi-scripts.git"'

