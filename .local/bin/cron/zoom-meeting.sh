#!/bin/sh

ZOOM_ID="{ID}"
ZOOM_PWD="{PWD}"
pid=$(pidof zoom)

[ -n "${1}" ] && [ -n "${2}" ] && ZOOM_ID="${1}" && ZOOM_PWD="${2}"

if [ -z "${pid}" ]; then
    xdg-open "zoommtg://zoom.us/join?action=join&confno=${ZOOM_ID}&pwd=${ZOOM_PWD}"
fi
