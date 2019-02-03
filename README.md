# Installation scripts for Raspberry Pi (Raspbian)

## Configuration

```bash
WIFI_SSID="my-rpi3"
WIFI_PASSWORD="my-rpi3-password"
WIFI_NETWORK="192.168.33"

git clone https://github.com/lhost/rpi-scripts.git
cd rpi-scripts
./rpi3-install.sh
```

## LCD configuraion

For LCD manual steps are required. Depends on model of your LCD display.


## Wifi hotspot with Raspberry Pi

Configure you Wifi network parameters and run
```bash
./wifi-access-point.sh
```


## NodeMCU webdriver

If you like to turn you RPi into remote control of your robots, run this command:
```bash
./nodemcu-webdriver.sh
```

