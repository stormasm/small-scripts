#!/bin/bash
# production: false

curr_level=$(xbacklight -get | awk -F. '{print $1}')

if [ $(($?)) -ne 0 ]; then
  exit 0
elif [[ $level =~ ^[0-9]+$ ]]; then
  xbacklight -set $level
else 
  notify-send "brightness-mgr Please enter an integer."
  exit 1
fi

function notify {
    notify-send -a "brightness-mgr" "brightness-mgr" "Brightness: $1%"
}

choice=$1
case $choice in 
    up)
        level=$(($curr_level))
        ;;
    down)
        ;;
    *)
        ;;
esac

