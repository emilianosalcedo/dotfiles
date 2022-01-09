#!/bin/sh

# wttr_params is space-separated URL parameters, many of which are single characters that can be
# lumped together. For example, "F q m" behaves the same as "Fqm".
wttr_params=""
url="https://wttr.in/"

if [ -z "${wttr_params}" ]; then
  # Form localized URL parameters for curl
  if [ -t 1 ] && [ "$(tput cols)" -lt 125 ]; then
      wttr_params+='n'
  fi 2> /dev/null

  for _token in $(locale LC_MEASUREMENT); do
    case "${_token}" in
      1) wttr_params+='m' ;;
      2) wttr_params+='u' ;;
    esac
  done 2> /dev/null

  unset _token
fi

wttr() {
  location="$(printf "%s\n" "${1}" | sed -e 's/ /+/g')"
  command shift
  args=""

  for p in ${wttr_params} "${@}"; do
    args+=" --data-urlencode $p "
  done

  curl -fGsS -H "Accept-Language: ${LANG%_*}" ${args} --compressed "${url}${location}"
}

wttr "${@}"
