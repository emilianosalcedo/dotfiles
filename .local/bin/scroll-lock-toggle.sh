#!/bin/sh

status=$(xset -q | awk '/Scroll/ { print $NF; }')

([ "$status" = "on" ] && xset -led 3) || xset led 3
