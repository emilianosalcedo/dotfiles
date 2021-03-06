#!/bin/sh

if [ "$1" = "All" ]; then
    if [ "$2" = "mute" ]; then
        volume="$(i3volume)"

        if [ ! "$(echo "$volume" | grep -q "mute")" ]; then
            amixer set "Master" "mute"
            amixer set "Headphone" "mute"
            amixer set "Speaker" "mute"
        else
            amixer set "Master" "unmute"
            amixer set "Headphone" "unmute"
            amixer set "Speaker" "unmute"
        fi
    fi
else
    amixer set "$1" "$2"
fi

pkill -SIGRTMIN+1 i3blocks
