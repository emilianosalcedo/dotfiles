#!/bin/sh

amount=10

handleclick() {
    if [ "$clicktype" = "up" ]; then
        case "$click" in
            "1") xdotool mouseup 1 ;;
            "2") xdotool mouseup 2 ;;
            "3") xdotool mouseup 3 ;;
            "4") xdotool mouseup 4 ;;
            "5") xdotool mouseup 5 ;;
        esac
    elif [ "$clicktype" = "down" ]; then
        case "$click" in
            "1") xdotool mousedown 1 ;;
            "2") xdotool mousedown 2 ;;
            "3") xdotool mousedown 3 ;;
            "4") xdotool mousedown 4 ;;
            "5") xdotool mousedown 5 ;;
        esac
    else
        case "$click" in
            "1") xdotool click 1 ;;
            "2") xdotool click 2 ;;
            "3") xdotool click 3 ;;
            "4") xdotool click 4 ;;
            "5") xdotool click 5 ;;
        esac
    fi

}

handlemove() {
    case "$Direction" in
        "left") xdotool mousemove_relative -- -$amount 0 ;;
        "right") xdotool mousemove_relative $amount 0 ;;
        "up") xdotool mousemove_relative -- 0 -$amount ;;
        "down") xdotool mousemove_relative 0 $amount ;;
        "up-left") xdotool mousemove_relative -- -$amount -$amount ;;
        "up-right") xdotool mousemove_relative -- $amount -$amount ;;
        "down-left") xdotool mousemove_relative -- -$amount $amount;;
        "down-right") xdotool mousemove_relative $amount $amount ;;
    esac
}

# LOOP OVER ARGUMENTS TO SCRIPT
for value in "$@"; do
  # HANDLE OPTIONS
  case "$value" in
    # OPTIONS REQURING ARGUMENTS
    -a|-m|-c|-u|-d) optionset=$value ;;
    -h|--help) helppage; exit 0 ;;
  esac

  # HANDLE ARGUMENTS
  if [ -n "$optionset" ]; then
    case "$optionset" in
      -a) amount=$value ;;
      -m) direction=$value ;;
      -u|-d) clicktype=$value ;;
      -c) click=$value ;;
      *) Err 1 "Invalid option set" ;;
    esac
  fi
done

if [ -n "$direction" ]; then
    handlemove
fi

if [ -n "$click" ]; then
    handleclick
fi
