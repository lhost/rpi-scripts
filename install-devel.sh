#!/bin/bash

KERNEL_HEADERS=linux-headers-amd64

# detect Raspberry Pi
if [ -f /proc/device-tree/model ]; then
	grep -q -i Raspberry /proc/device-tree/model
	if [ $? -eq 0 ]; then
		KERNEL_HEADERS=raspberrypi-kernel-headers
	fi
fi

apt-get install -y \
	debhelper \
	dh-autoreconf \
	dh-exec \
	dh-make \
	dh-strip-nondeterminism \
	build-essential \
	gdb libtool \
	dkms module-assistant \
	dpkg-dev \
	$KERNEL_HEADERS

exit 0

# vim: fdm=marker fdl=0 fdc=3
