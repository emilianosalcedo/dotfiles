#!/usr/bin/env sh

HDMI_STATUS=$(cat /sys/class/drm/card0/*HDMI*/status)

if [ "$HDMI_STATUS" = "connected" ]; then
  #xrandr --output HDMI1 --mode 1920x1080 --output LVDS1 --off
  #xrandr --output HDMI1 --size 1920x1080 --output LVDS1 --off
  xrandr --output HDMI1 --auto --output LVDS1 --off
  pactl set-card-profile 0 output:hdmi-stereo
elif [ "$HDMI_STATUS" = "disconnected" ]; then
  xrandr --output LVDS1 --auto --output HDMI1 --off
  pactl set-card-profile 0 output:analog-stereo
else
  exit
fi

case "$chosen" in
	laptopdual) xrandr --output LVDS-1 --auto --output VGA-1 --auto --right-of LVDS-1 ;;
	laptop) xrandr --output LVDS-1 --auto --output VGA-1 --off ;;
	VGA) xrandr --output VGA-1 --auto --output LVDS-1 --off ;;
	HDMI) xrandr --output HDMI-1 --auto --output LVDS-1 --off ;;
	"Manual selection") arandr ;;
esac

