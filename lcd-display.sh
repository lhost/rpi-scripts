#!/bin/bash
# vim: ft=sh fdm=marker

sudo apt-get install -y \
	matchbox-keyboard \
	lxterminal \
	raspberrypi-ui-mods rpi-chromium-mods \
	realvnc-vnc-viewer \
	xinput-calibrator \
	xinit \
	xserver-xorg-video-fbturbo \
	gldriver-test \
	point-rpi

sudo apt-get purge -y termit

# LCD {{{
git clone https://github.com/waveshare/LCD-show.git waveshare-LCD-show
git clone https://github.com/goodtft/LCD-show goodtft-LCD-show
 # }}}

# lxterminal {{{
mkdir -p ~/.config/lxterminal/
# lxterminal.conf {{{
cat > ~/.config/lxterminal/lxterminal.conf <<EOF
[general]
fontname=Monospace 12
#selchars=-A-Za-z0-9,./?%&#:_
selchars=-A-Za-z0-9,./?%&#_
scrollback=1000
bgcolor=#000000000000
bgalpha=65535
fgcolor=#aaaaaaaaaaaa
palette_color_0=#000000000000
palette_color_1=#aaaa00000000
palette_color_2=#0000aaaa0000
palette_color_3=#aaaa55550000
palette_color_4=#00000000aaaa
palette_color_5=#aaaa0000aaaa
palette_color_6=#0000aaaaaaaa
palette_color_7=#aaaaaaaaaaaa
palette_color_8=#555555555555
palette_color_9=#ffff55555555
palette_color_10=#5555ffff5555
palette_color_11=#ffffffff5555
palette_color_12=#55555555ffff
palette_color_13=#ffff5555ffff
palette_color_14=#5555ffffffff
palette_color_15=#ffffffffffff
color_preset=VGA
disallowbold=false
cursorblinks=false
cursorunderline=false
audiblebell=false
tabpos=top
geometry_columns=72
geometry_rows=24
hidescrollbar=true
hidemenubar=true
hideclosebutton=false
hidepointer=false
disablef10=false
disablealt=false
disableconfirm=false

[shortcut]
new_window_accel=<CTRL><SHIFT>N
new_tab_accel=<CTRL><SHIFT>T
close_tab_accel=<CTRL><SHIFT>W
close_window_accel=<CTRL><SHIFT>Q
copy_accel=<CTRL><SHIFT>C
paste_accel=<CTRL><SHIFT>V
name_tab_accel=<CTRL><SHIFT>I
previous_tab_accel=<CTRL>Page_Up
next_tab_accel=<CTRL>Page_Down
move_tab_left_accel=<CTRL><SHIFT>Page_Up
move_tab_right_accel=<CTRL><SHIFT>Page_Down
zoom_in_accel=<CTRL>plus
zoom_out_accel=<CTRL>underscore
zoom_reset_accel=<CTRL>parenright
EOF
# }}}

cat > ~/Desktop/lxterminal.desktop <<EOF
[Desktop Entry]
Type=Link
Name=Terminal
Icon=lxterminal
URL=/usr/share/raspi-ui-overrides/applications/lxterminal.desktop
EOF

# }}}

cat > ~/Desktop/inputmethods-matchbox-keyboard.desktop <<EOF
[Desktop Entry]
Type=Link
Name=Keyboard
Icon=matchbox-keyboard
URL=/usr/share/applications/inputmethods/matchbox-keyboard.desktop
EOF

cat > ~/Desktop/Chrome.desktop <<EOF
[Desktop Entry]
Type=Link
Name=Chromium Web Browser
Icon=chromium-browser
URL=/usr/share/applications/chromium-browser.desktop
EOF

cd waveshare-LCD-show/
./LCD35C-show

# TODO: change options in /boot/config.txt
#
#    #hdmi_cvt 480 320 60 6 0 0 0
#    #hdmi_cvt 1024 768 60 6 0 0 0
#    hdmi_cvt 800 600 60 6 0 0 0

