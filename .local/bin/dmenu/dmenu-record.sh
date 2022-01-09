#!/bin/sh

list="window\nfull\nregion\nnomic\nall\nwatermark\noverlay\nmonitor\nwebcam\nmic\ninternal\nall-audio\ngif\ngif-low\nkill"
choice="$(dmenu.sh p "record:" "${list}")"
recpid="/tmp/recordingpid"

case "${choice}" in
  "window") screen-capture.sh "${choice}" ;;
  "full") screen-capture.sh "${choice}" ;;
  "region") screen-capture.sh "${choice}" ;;
  "nomic") screen-capture.sh "${choice}" ;;
  "all") screen-capture.sh "${choice}" ;;
  "watermark") screen-capture.sh "${choice}" ;;
  "overlay") screen-capture.sh "${choice}" ;;
  "monitor") screen-capture.sh "${choice}" ;;
  "webcam") screen-capture.sh "${choice}" ;;
  "mic") screen-capture.sh "${choice}" ;;
  "internal") screen-capture.sh "${choice}" ;;
  "all-audio") screen-capture.sh "${choice}" ;;
  "gif"*) screen-capture.sh "${choice}" ;;
  "kill") [ -f "${recpid}" ] && screen-capture.sh "${choice}" ;;
  *) exit 0 ;;
esac
