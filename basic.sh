#!/bin/bash
# vim: ft=sh fdm=marker

sudo apt-get install -y \
	git etckeeper screen mc vim ssh liquidprompt \
	deborphan \
	rename \
	lm-sensors i2c-tools


# liquidprompt
liquidprompt_activate
sudo liquidprompt_activate

#sudo apt -y purge "pulseaudio*"

