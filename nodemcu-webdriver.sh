#!/bin/bash
# vim: ft=sh fdm=marker

MQTT_HOST="${MQTT_HOST:-192.168.137.1}"
MQTT_USER="${MQTT_USER:-robot}"
MQTT_PASSWORD="${MQTT_PASSWORD:-robot}"

sudo apt-get install -y \
	python-sense-emu python3-sense-emu python-sense-emu-doc \
	python-configparser \
	python-flask python-pip \
	rabbitmq-server \
	nginx gunicorn

# rabbgitmq
sudo rabbitmq-plugins enable rabbitmq_management rabbitmq_mqtt
sudo rabbitmqctl add_user  $MQTT_USER $MQTT_PASSWORD
sudo rabbitmqctl set_user_tags $MQTT_USER administrator
sudo rabbitmqctl set_permissions -p / $MQTT_USER ".*" ".*" ".*"

# python
sudo python -m pip install paho-mqtt esptool adafruit-ampy requests click

# webdriver {{{
cd /home/pi
git clone https://github.com/lhost/mqtt-robot-webdriver/
git clone https://github.com/lhost/mqtt-robot-nodemcu
cat > ~/mqtt-robot-webdriver/driver.ini <<EOF
[webdriver]
listen = 0.0.0.0
port = 5000

[mqtt-server]
host = $MQTT_HOST
username = $MQTT_USER
password = $MQTT_PASSWORD

EOF
# }}}

#
# Configure gunicorn
#
sudo tee /etc/systemd/system/webdriver.service <<EOF
[Unit]
Description = NodeMCU webdriver
After = network.target rabbitmq-server.service
Wants=network.target rabbitmq-server.service

[Service]
PermissionsStartOnly = true
PIDFile = /run/webdriver/webdriver.pid
RemainAfterExit=no
Restart=on-failure
RestartSec=2m
User = www-data
Group = www-data
WorkingDirectory = /home/pi/mqtt-robot-webdriver
ExecStartPre = /bin/mkdir -p /run/webdriver
ExecStartPre = /bin/chown -R www-data:www-data /run/webdriver
ExecStart = /usr/bin/env gunicorn -b 0.0.0.0:5000 --pid /run/webdriver/webdriver.pid wsgi
ExecReload = /bin/kill -s HUP \$MAINPID
ExecStop = /bin/kill -s TERM \$MAINPID
ExecStopPost = /bin/rm -rf /run/webdriver
PrivateTmp = true

[Install]
WantedBy = multi-user.target
EOF

sudo chmod 755 /etc/systemd/system/webdriver.service
sudo systemctl daemon-reload
sudo systemctl enable webdriver
sudo service webdriver restart

#
# Configure nginx
#
rm -f /etc/nginx/sites-enabled/default
sudo tee /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Welcome to Raspberry Pi</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to Raspberry Pi!</h1>
<ul>
  <li><a href="/rmq/">RabbitMQ web interface</a></li>
  <li><a href="/robot/">Robot joistick</a></li>
</ul>
</body>
</html>
EOF

sudo tee /etc/nginx/proxy-setting.conf <<EOF
proxy_redirect  off;
proxy_set_header Host            \$host;
proxy_set_header X-Real-IP       \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-HTTPS         \$scheme;
proxy_set_header X-REMOTE-ADDR   \$remote_addr;
proxy_set_header X-REMOTE-PORT   \$remote_port;
proxy_set_header X-SERVER-ADDR   \$server_addr;
proxy_set_header X-SERVER-NAME   \$server_name;
proxy_set_header X-SERVER-PORT   \$server_port;
EOF


sudo tee /etc/nginx/sites-available/robot <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/html;

    location /rmq/ {
        proxy_pass  http://localhost:15672/;
        include /etc/nginx/proxy-setting.conf;
    }
    
    location /static/ {
        access_log off;
        proxy_pass  http://127.0.0.1:5000/static/;
        include /etc/nginx/proxy-setting.conf;
    }
    location /robot/ {
        if (\$request_method = POST) {
            access_log off;
        }
        proxy_pass  http://localhost:5000/;
        include /etc/nginx/proxy-setting.conf;
    }
}
EOF

sudo ln -s -f /etc/nginx/sites-available/robot /etc/nginx/sites-enabled/ \
	&& sudo rm -f /etc/nginx/sites-enabled/default
sudo service nginx reload

sudo etckeeper commit -m 'Installed NodeMCU webdriver'

