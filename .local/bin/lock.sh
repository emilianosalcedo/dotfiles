#!/bin/sh

icon="${XDG_DATA_HOME}/lock.png"
wall="${XDG_DATA_HOME}/wall.png"
img="/tmp/screen.png"
full="$(xrandr -q | awk '/\sconnected/ { print $4; }' | cut -d '+' -f 1)"

take_screenshot() {
  maim "${img}"
}

resize() {
  convert "${wall}" -resize "${full}"\! "${img}"
}

pixelate() {
  convert "${img}" -scale 10% -scale 1000% "${img}"
}

blur_image() {
  convert "${img}" -blur 0x4 500% "${img}"
}

compose_images() {
  convert "${img}" "$icon" -gravity center -composite -matte "${img}"
}

pause_media() {
  #playerctl --all-players pause
  pause-media.sh
}

lock_screen() {
  i3lock --nofork -i "${img}"
}

clean() {
  rm "${img}"
}

pic() {
  take_screenshot
  pixelate
  compose_images
}

back() {
  resize
  compose_images
}

case "${1}" in
  "pic") pause_media && pic && lock_screen ;;
  "back") pause_media && back && lock_screen ;;
  "clean") clean ;;
  *) 
    pause_media

    if [ -e "${img}" ]; then
      lock_screen
    else
      back && lock_screen
    fi
    ;;
esac
