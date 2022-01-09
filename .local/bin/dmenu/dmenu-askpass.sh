#!/bin/sh

# This script is the SUDO_ASKPASS variable, meaning that it will be used as a
# password prompt if needed.

. "${XDG_CONFIG_HOME}/dmenu/dmenurc"

dmenu $DMENU_OPTS "$DMENU_FN" -p "$1" <&- && echo
