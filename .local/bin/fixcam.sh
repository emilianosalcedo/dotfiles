#!/bin/sh

device=$(v4l2-ctl --list-devices 2>/dev/null | grep -A 1 "USB 2.0 Camera" | grep -o "/dev/video.")

if [ -n "${device}" ]; then
  v4l2-ctl -d ${device} --set-ctrl=exposure_auto=3
  #v4l2-ctl -d ${device} --set-ctrl=exposure_absolute=200
  v4l2-ctl -d ${device} --set-ctrl=white_balance_temperature_auto=1
  #v4l2-ctl -d ${device} --set-ctrl=white_balance_temperature=4600
  v4l2-ctl -d ${device} --set-ctrl=saturation=96
  v4l2-ctl -d ${device} --set-ctrl=contrast=16
  v4l2-ctl -d ${device} --set-ctrl=sharpness=6
  v4l2-ctl -d ${device} --set-ctrl=brightness=-16
  v4l2-ctl -d ${device} --set-ctrl=gain=12
  v4l2-ctl -d ${device} --set-ctrl=gamma=90
  v4l2-ctl -d ${device} --set-ctrl=hue=0
  v4l2-ctl -d ${device} --set-ctrl=backlight_compensation=2
  #v4l2-ctl -d ${device} --set-fmt-video=width=1920,height=1080
fi
