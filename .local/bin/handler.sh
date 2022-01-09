#!/bin/sh

video() { setsid env MPV="mpv --ytdl-format=22 --quiet" umpv.py "${@}" >/dev/null 2>&1 & }
streaming() { setsid streamlink "${@}" >/dev/null 2>&1 & }
img() { setsid feh "${@}" >/dev/null 2>&1 & }
dl() { setsid tsp curl -LO "${@}" >/dev/null 2>&1 & }
ytdl() { setsid tsp youtube-dl --add-metadata -ic "${@}" >/dev/null 2>&1 & }

case "${1}" in
  *mkv|*webm|*mp4)
    video "${@}" ;;
  *youtube.com/watch*|*youtube.com/playlist*|*youtu.be*|*hooktube.com*|*bitchute.com*)
    video "${@}" ;;
  *twitcht.tv*)
    streaming "${@}" ;;
  *png|*jpg|*jpe|*jpeg)
    img "${@}" ;;
  *gif)
    video "${@}" ;;
    #img "${@}" ;;
  *mp3|*flac|*opus|*mp3?source*|pdf)
    dl "${@}" ;;
  *html)
    ${BROWSER} "${@}" ;;
  *)
    exit 0 ;;
esac
