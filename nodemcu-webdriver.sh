#!/bin/bash
# vim: ft=sh fdm=marker

MQTT_HOST="${MQTT_HOST:-192.168.137.1}"
MQTT_USER="${MQTT_USER:-robot}"
MQTT_PASSWORD="${MQTT_PASSWORD:-robot}"

sudo apt-get install -y \
	python-sense-emu python3-sense-emu python-sense-emu-doc \
	python-configparser \
	python-flask python-pip \
	rabbitmq-server

# rabbgitmq
rabbitmq-plugins enable rabbitmq_management rabbitmq_mqtt
rabbitmqctl add_user  $MQTT_USER $MQTT_PASSWORD
rabbitmqctl set_user_tags $MQTT_USER administrator
rabbitmqctl set_permissions -p / $MQTT_USER ".*" ".*" ".*"

# python
python -m pip install paho-mqtt esptool adafruit-ampy requests click

# webdriver {{{
git clone https://github.com/lhost/mqtt-robot-webdriver/
git clone https://github.com/lhost/mqtt-robot-nodemcu
cat > ~/mqtt-robot-webdriver/driver.ini <<EOF
[mqtt-server]
host = $MQTT_HOST
username = $MQTT_USER
password = $MQTT_PASSWORD

; check status http://www.mqtt-dashboard.com/
; username = xxx
; password = xxx
EOF
# }}}


