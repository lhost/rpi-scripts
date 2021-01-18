#!/bin/bash
# vim: ft=sh fdm=marker

WIFI_SSID="${WIFI_SSID:-rpi3}"
WIFI_PASSWORD="${WIFI_PASSWORD:-rpi345678pass}"
WIFI_NETWORK="${WIFI_NETWORK:-192.168.33}"

if [ "$EUID" -ne 0 ]; then
	exec sudo $0
fi

apt-get install -y \
	hostapd dnsmasq

grep -q iptables /etc/rc.local || echo iptables >> /etc/rc.local
sed -i -e "s/^exit 0//g; s/^iptables/iptables -t nat -A POSTROUTING -s $WIFI_NETWORK.0\/24 ! -d $WIFI_NETWORK.0\/24 -j MASQUERADE/g;" /etc/rc.local

iptables-save | grep -q MASQUERADE || /etc/rc.local

[ -f /etc/network/interfaces.d/eth0 ] || cat > /etc/network/interfaces.d/eth0 <<EOF
auto eth0
iface eth0 inet dhcp
EOF

[ -f /etc/network/interfaces.d/lo ] || cat > /etc/network/interfaces.d/lo <<EOF
auto lo
iface lo inet loopback
EOF

[ -f /etc/network/interfaces.d/wlan0 ] || cat > /etc/network/interfaces.d/wlan0 <<EOF
auto wlan0
iface wlan0 inet static
	hostapd /etc/hostapd/hostapd.conf
	address $WIFI_NETWORK.1
	netmask 255.255.255.0
EOF

[ -f /etc/hostapd/hostapd.conf ] || cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
ssid=$WIFI_SSID
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$WIFI_PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

cat > /etc/dnsmasq.d/$WIFI_SSID.conf <<EOF
interface=wlan0
bind-interfaces
resolv-file=/dev/null
bogus-priv
listen-address=$WIFI_NETWORK.1
no-dhcp-interface=lo,eth0
dhcp-range=$WIFI_NETWORK.2,$WIFI_NETWORK.254,255.255.255.0,12h
address=/#/$WIFI_NETWORK.1
EOF

grep -q $WIFI_NETWORK.1  /etc/hosts || echo "$WIFI_NETWORK.1 $WIFI_SSID.local robot" >> /etc/hosts
grep -q DNSMASQ_EXCEPT /etc/default/dnsmasq || echo "DNSMASQ_EXCEPT=lo" >> /etc/default/dnsmasq
sed -i -e 's/^DNSMASQ_EXCEPT=.*$/DNSMASQ_EXCEPT=lo/g' /etc/default/dnsmasq

cat > /etc/sysctl.d/ip_forward.conf <<EOF
net.ipv4.ip_forward=1
EOF

tee /etc/nginx/sites-available/captive-portal <<EOF
server {
		listen 80 default_server;
		listen [::]:80 default_server;
		server_name _;

		#rewrite ^ http://robot/;

		root /var/www/html;

		index index.html;
		# Handle iOS
		if (\$http_user_agent ~* (CaptiveNetworkSupport) ) {
			return 302 http://robot/;
		}

		if (\$request_method !~ ^(GET|HEAD|POST)$) { return 444; }
		location / {
			return 302 http://robot/;
		}
#       location /letsconnect {
#               # First attempt to serve request as file, then
#               # as directory, then fall back to displaying a 404.
#               try_files \$uri \$uri/ =404;
#       }
}
EOF

ln -s -f /etc/nginx/sites-available/captive-portal /etc/nginx/sites-enabled/ \
	&& rm -f /etc/nginx/sites-enabled/default
service nginx reload
