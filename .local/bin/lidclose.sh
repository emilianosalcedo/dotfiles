#!/usr/bin/env sh

grep -q closed /proc/acpi/button/lid/LID0/state

if [ $? = 0 ]; then
  grep -q 0 /sys/class/power_supply/ADP1/online
  if [ $? = 0 ]; then
    systemctl suspend
  fi
fi
