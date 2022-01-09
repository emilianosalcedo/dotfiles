#!/bin/sh

wallpaper="${XDG_DATA_HOME}/wall.png"
location="$(readlink -f "${1}")"
ftype="$(file --mime-type -b "${location}")"

if [ -n "${1}" ]; then
  case "${ftype}" in
    "image/"*) ln -sf "${location}" "${wallpaper}" ;;
    "inode/directory")
      fdir="$(find "${location}" -type f -iregex '.*\.\(jpeg\|jpg\|png\|gif\)')"
      rand="$(printf "%s" "${fdir}" | shuf -n 1)"
      ln -sf "${rand}" "${wallpaper}"
      notify-send -i "${wallpaper}" "Wallpaper changed"
      ;;
    *) exit 1 ;;
  esac
fi

xwallpaper --zoom "${wallpaper}"
