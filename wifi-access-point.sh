#!/bin/bash
# vim: ft=sh fdm=marker


WIFI_SSID="${WIFI_SSID:-rpi3}"
WIFI_PASSWORD="${WIFI_PASSWORD:-rpi345678pass}"
WIFI_NETWORK="${WIFI_NETWORK:-192.168.33}"

sudo apt-get install -y \
	hostapd dnsmasq

echo "iptables -t nat -A POSTROUTING -s $WIFI_NETWORK.0/24 ! -d $WIFI_NETWORK.0/24 -j MASQUERADE" | sudo tee -a /etc/rc.local

[ -f /etc/network/interfaces.d/eth0 ] || sudo cat > /etc/network/interfaces.d/eth0 <<EOF
auto eth0
iface eth0 inet dhcp
EOF

[ -f /etc/network/interfaces.d/lo ] || sudo cat > /etc/network/interfaces.d/lo <<EOF
auto lo
iface lo inet loopback
EOF

[ -f /etc/network/interfaces.d/wlan0 ] || sudo cat > /etc/network/interfaces.d/wlan0 <<EOF
auto wlan0
iface wlan0 inet static
	hostapd /etc/hostapd/hostapd.conf
	address $WIFI_NETWORK.1
	netmask 255.255.255.0
EOF

[ -f /etc/hostapd/hostapd.conf ] || sudo cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=nl80211
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

sudo cat > /etc/dnsmasq.d/$WIFI_SSID.conf <<EOF
interface=lo,wlan0
no-dhcp-interface=lo
dhcp-range=$WIFI_NETWORK.2,$WIFI_NETWORK.254,255.255.255.0,12h
EOF


