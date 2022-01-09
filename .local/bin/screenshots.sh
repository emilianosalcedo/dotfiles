#!/bin/sh

{ [ -n "${2}" ] && format="${2}"; } || format="png"
dir="$(xdg-user-dir PICTURES)/screenshots/"
time="$(date +'%Y%m%d%H%M%S')"
output="${dir}screenshot_${time}.${format}"
monitor="$(xrandr -q | grep $(xrandr --listmonitors | awk '/HDMI/ { print $4; }') | awk '{ print $4; }')"
help="Usage:
  $(basename ${0}) [options] [format]

Options:
  region
  window-active
  window-title
  window-select"

scan_qr() {
  tmp_file="$(mktemp -t screenshot-XXXXXX)"
  maim -u -g "$(slop)" "${tmp_file}"
  scanresult="$(zbarimg --quiet --raw "${tmp_file}" | tr -d '\n')"

  if [ -n "${scanresult}" ]; then
    printf "${scanresult}" | xclip -selection clipboard -in
    mogrify "${tmp_file}" -resize 50x50
    notify-send -i "${tmp_file}" "QR" "${scanresult}\n(copied to clipboard)"
  fi

  rm "${tmp_file}"
}

case "${1}" in
  "region") maim -u -s "${output}" ;;
  "window-active") maim -u -i "$(xdotool getactivewindow)" "${output}" ;;
  "window-title") maim -u "${output}" ;;
  "window-select") maim -u -g "$(slop)" "${output}" ;;
  "full") maim -u -g "${monitor}" "${output}" ;;
  "copy") maim -u -s | xclip -selection clipboard -in -t image/png ;;
  "qr") scan_qr ;;
  *) printf "%s\n" "${help}" && exit ;;
esac

[ "${2}" = "open" ] && $IMAGE "${output}"
