#!/bin/bash

# https://www.pyimagesearch.com/2015/11/30/detecting-machine-readable-zones-in-passport-images/
# https://pillow.readthedocs.io/en/latest/installation.html

apt-get install -y \
	python3-pip \
	python3-dev \
	python3-setuptools \
	tesseract-ocr \
	gimagereader \
	libtesseract-dev \
	libjpeg9-dev \
	zlib1g-dev \
	libtiff5-dev \
	python-sphinx python-sphinx-rtd-theme python-sphinxcontrib.spelling python-mock python-pil python-opencv python-wand


for pythonpkg in PassportEye tensorflow numpy scipy opencv-python pillow matplotlib h5py keras imageai imutils ; do
	echo -------------------- $pythonpkg ------------;
	pip3 install $pythonpkg --upgrade;
done

