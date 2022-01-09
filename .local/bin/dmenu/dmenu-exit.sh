#!/bin/sh

list="logout\nlock\nshutdown\nreboot\nsuspend\nhibernate"
choice="$(dmenu.sh p "exit:" "${list}")"

#pkill -15 Xorg
#pkill -15 -t tty"$XDG_VTNR" Xorg

case "$choice" in
  logout) pkill -KILL -u "${USER}" ;;
  lock) lock.sh || lock.sh back ;;
  shutdown) shutdown -h now ;;
  reboot) shutdown -r now ;;
  suspend) systemctl suspend ;;
  hibernate) systemctl hibernate ;;
  *) exit ;;
esac
