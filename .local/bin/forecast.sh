#!/bin/sh

weatherreport="${XDG_DATA_HOME:-$HOME/.local/share}/weather.txt"
currenttemp="${XDG_DATA_HOME:-$HOME/.local/share}/current-weather.txt"
filetime="$(stat -c %y "${weatherreport}" 2>/dev/null | cut -d ' ' -f 1)"
temptime="$(stat -c %y "${currenttemp}" 2>/dev/null | awk '{ print $2; }' | cut -d ':' -f 1)"
timestamp="$(date '+%Y-%m-%d')"
hour="$(date '+%H')"
url="https://wttr.in/${LOCATION}"

getforecast() {
  command curl -sf "${url}?m3&lang=es" > "${weatherreport}" || exit 1
}

getcurrent() {
  command curl -sf "${url}?m3&lang=es&format=1" > "${currenttemp}" || exit 1
}

showweather() {
  printf "%s" "$(sed '16q; d' "${weatherreport}" |\
    grep -wo "[0-9]*%" |\
    sort -rn |\
    sed 's/^//g; 1q' |\
    tr -d '\n')"

  sed '13q; d' "${weatherreport}" |\
    grep -o "m\\([-+]\\)*[0-9]\\+" |\
    sed 's/+//g' |\
    sort -n -t 'm' -k 2n |\
    sed -e 1b -e '$!d' |\
    tr '\n|m' ' ' |\
    awk '{ print " " $1 "°","" $2 "°"; }'
}

showcurrent() {
  if grep -q -m 1 "Unknown" "${currenttemp}"; then
    showweather | awk '{ print $3 }'
  else
    cat "${currenttemp}"
  fi
}

[ "${filetime}" = "${timestamp}" ] ||	getforecast
[ "${temptime}" = "${hour}" ] ||	getcurrent

case "${1}" in
  "all") cat "${weatherreport}" ;;
  "temp") showcurrent ;;
  *) showweather ;;
esac
