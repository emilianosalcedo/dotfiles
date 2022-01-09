#!/bin/sh

[ -f "${XDG_CONFIG_HOME}/dmenu/dmenurc" ] && . "${XDG_CONFIG_HOME}/dmenu/dmenurc"
[ "${1}" = "p" ] && prompt="-p" && title="${2}" && shift 2
[ "${1}" = "l" ] && lines="-p" && long="${2}" && shift 2

case "${1}" in
  "desktop") j4-dmenu-desktop --dmenu="${J4_OPTS} -p "run:"" ;;
  "run") dmenu_run -p "run:" $DMENU_OPTS "$DMENU_FN" ;;
  "")
    if [ -n "${prompt}" ]; then
      dmenu "${prompt}" "${title}" $DMENU_OPTS "$DMENU_FN"
    else
      dmenu $DMENU_OPTS "$DMENU_FN"
    fi
    ;;
  *)
    if [ -n "${prompt}" ] && [ -z "${lines}" ]; then
      printf "${@}" | dmenu "${prompt}" "${title}" $DMENU_OPTS "$DMENU_FN"
    elif [ -n "${prompt}" ] && [ -n "${lines}" ]; then
      printf "${@}" | dmenu "${prompt}" "${title}" -l "${long}" $DMENU_OPTS "$DMENU_FN"
    elif [ -z "${prompt}" ] && [ -n "${lines}" ]; then
      printf "${@}" | dmenu -l "${long}" $DMENU_OPTS "$DMENU_FN"
    else
      printf "${@}" | dmenu $DMENU_OPTS "$DMENU_FN"
    fi
    ;;
esac
