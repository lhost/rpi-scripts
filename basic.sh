#!/bin/bash
# vim: ft=sh fdm=marker

sudo apt-get install -y \
	git etckeeper screen mc vim ssh liquidprompt

# liquidprompt
liquidprompt_activate
sudo liquidprompt_activate

sudo apt -y purge "pulseaudio*"

