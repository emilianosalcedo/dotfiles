#!/bin/sh

if [ "$1" = "output-vol" ]; then
  pactl set-sink-mute "$2" false
  pactl set-sink-volume "$2" "$3"
else
  pactl set-sink-mute "$2" toggle
fi

device=$(pulsedevices | grep "pci-0000_0b" -A 2)
vol=$(echo "$device" | grep "front-left" | awk '{ print $5 }' | tr -d "%")

#pkill -SIGTRAP pulseupdate
pkill -SIGRTMIN+1 i3blocks
