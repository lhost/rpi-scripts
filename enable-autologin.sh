#!/bin/bash

sudo sed -i -e 's/^\s*#\s*autologin-user=/autologin-user=/g; s/autologin-user=.*$/autologin-user=pi/g' /etc/lightdm/lightdm.conf
