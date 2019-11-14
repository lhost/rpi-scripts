#!/bin/bash

apt-get install -y \
	python3-pip

for pythonpkg in tensorflow numpy scipy opencv-python pillow matplotlib h5py keras imageai ; do
	echo -------------------- $pythonpkg ------------;
	pip3 install $pythonpkg --upgrade;
done

