#!/bin/sh

list="region\nwindow-active\nwindow-select\nwindow-title\nfullscreen\ncopy\nqr"
choice="$(dmenu.sh p "screenshot:" "${list}")"

case "$choice" in
  "region") screenshots.sh "${choice}" ;;
  "window-active") screenshots.sh "${choice}" ;;
  "window-select") screenshots.sh "${choice}" ;;
  "window-title") screenshots.sh "${choice}" ;;
  "full"*) screenshots.sh "${choice:+full}" ;;
  "copy"*) screenshots.sh "${choice:+copy}" ;;
  "qr"*) screenshots.sh "${choice:+qr}" ;;
  *) exit;;
esac
