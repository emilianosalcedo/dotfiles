#!/bin/sh

#xclip -o -sel clip >> ~/.clipboard

options="list\nselect\ndelete"
menu="$(dmenu.sh p "clipboard:" ${options})"
list="$(clipster.py -o -c -n 0 | grep -v "^$")"
long="$(echo "${list}" | wc -l)"
cant="$(dc -e "${long} 2 / pq")"

list_select() {
  [ -n "${list}" ] && choice="$(dmenu.sh p "clipboard:" l "20" "${list}")"
  [ -n "${choice}" ] && clipster.py -c -r "${choice}" && echo "${choice}" | xclip -sel c
}

delete() {
  clipster.py -c --erase-entire-board 
  clipster.py -p --erase-entire-board 
  xclip -selection primary -i /dev/null
}

case "${menu}" in
  "list") list_select ;;
  "select") clipster.py -c -s ;;
  "delete") delete ;;
  *) exit ;;
esac
