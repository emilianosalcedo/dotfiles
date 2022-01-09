#!/bin/sh

typeit=0

if [ "${1}" = "--type" ]; then
	typeit=1
	shift
fi

if [ -n "${DISPLAY}" ]; then
	dmenu=dmenu.sh
	xdotool="xdotool type --clearmodifiers --file -"
else
	echo "Error: No X11 display detected" >&2
	exit 1
fi

prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files="$(find "${prefix}" -type f -iname "*.gpg" | sed "s@${prefix}/@@g; s/.gpg//g" | sort)"
password="$("${dmenu}" p "pass" "${password_files}")"

[ -n "${password}" ] || exit

if [ "${typeit}" -eq 0 ]; then
	pass show -c "${password}" 2>/dev/null
else
	pass show "${password}" | { IFS= read -r pass; printf %s "${pass}"; } | ${xdotool}
fi
