#!/bin/sh

mpv_socket="/tmp/mpv_socket"
umpv_socket="${HOME}/.umpv_socket"
mpd_state="${XDG_CONFIG_HOME}/mpd/state"
all_sockets="/tmp/mpvSockets/"

[ -e "${mpd_state}" ] && grep -q -m 1 "state: play" "${mpd_state}" && mpc pause
[ -e "${mpv_socket}" ] && printf "%s\n" '{ "command": ["set_property", "pause", true], "async": true }' | socat - "${mpv_socket}" >/dev/null 2>&1 &
[ -e "${umpv_socket}" ] && printf "%s\n" '{ "command": ["set_property", "pause", true], "async": true }' | socat - "${umpv_socket}" >/dev/null 2>&1 &

if [ -d "${all_sockets}" ]; then
  for i in $(ls "${all_sockets}"*); do
    printf "%s\n" '{ "command": ["set_property", "pause", true], "async": true }' | socat - "${i}" >/dev/null 2>&1 &
  done
fi
