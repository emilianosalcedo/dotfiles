#!/bin/sh

image="$(readlink -f "${1}")"
img_sufless="${1%%.*}"
ftype="$(file --mime-type -b "${image}")"
ext="${2:-png}"
temp="$(mktemp)"
output_diff="${temp}.${ext}"
output_trans="result.${ext}"

{ [ -n "${2}" ] && shift 2; } || shift
mv "${temp}" "${output_diff}"

if [ -n "${image}" ]; then
  case "${ftype}" in
    "image/"*)
      convert "${image}" \( +clone -fx 'p{10,10}' \) -compose Difference -composite -modulate 1,0 "${output_diff}"
      convert "${image}" "${output_diff}" -compose Copy_Opacity -composite "${output_trans}"

      for i in $(seq 1 1 20); do
        convert "${output_trans}" +clone -background none -flatten "${output_trans}"
        sleep 0.1
      done
      ;;
    *) exit 1 ;;
  esac
fi

rm "${output_diff}"
