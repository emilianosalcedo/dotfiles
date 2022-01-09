#!/usr/bin/env sh

# toggle state of touchpad

sleep 0.2

tpid=$(xinput list | grep "ETPS/2 Elantech Touchpad" | sed 's/.*id\=\([0-9]\+\).*/\1/g')

set status
status=$(xinput list-props "${tpid}" | grep Device\ Enabled | sed -e 's/.*\:[ \t]\+//g')

if [ 0 -eq "${status}" ]; then
	xinput enable "${tpid}"
	notify-send "Touchpad" "Activado" -i /usr/share/icons/Papirus-Dark/symbolic/status/touchpad-enabled-symbolic.svg
else
	xinput disable "${tpid}"
	notify-send "Touchpad" "Desactivado" -i /usr/share/icons/Papirus-Dark/symbolic/status/touchpad-disabled-symbolic.svg 
fi
