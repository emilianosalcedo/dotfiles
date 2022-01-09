#!/usr/bin/env sh

sudo rmmod xpad
sudo modprobe xpad
echo "2e24 1688" | sudo tee -a /sys/bus/usb/drivers/xpad/new_id
