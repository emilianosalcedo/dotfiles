#!/bin/sh

equation=$(printf "%s\n" "=" | dmenu.sh p "calc" | bc)

[ -n "${equation}" ] && \
  notify-send -i "calc" "Result" "${equation}" && \
  printf "%s" "${equation}" | xclip -selection primary -in
