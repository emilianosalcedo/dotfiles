#!/bin/sh

google-chrome --incognito "https://www.argentina.gob.ar/circular/"
sleep 7
wmctrl -a Argentina
xdotool mousemove 400 600
xdotool click 1

for i in $(seq 1 1 4); do
  xdotool key Tab
done

xdotool key Return
sleep 2

for i in $(seq 1 1 9); do
  xdotool key Tab
done 

xdotool key space
xdotool key Tab
xdotool key Return 
sleep 2
xdotool mousemove 400 400
xdotool click 1 
xdotool key Tab
xdotool key space
xdotool type "Ciudad"
xdotool key Return
xdotool key Tab
xdotool key Return
sleep 1
xdotool key Tab
xdotool key Tab
xdotool key Down 
xdotool key Tab 
xdotool key Down 
xdotool key Tab 
xdotool key Return
