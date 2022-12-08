#!/bin/bash
# display-mgr.sh


displays=$(xrandr | grep -i ' connected' | awk '{ print $1 }')

configs=()
index=0
for display1 in $displays; do
    for display2 in $displays; do
        if [ $display1 == $display2 ]; then
            display2=""
        fi
        configs[$index]="$index $display1 $display2 \n"
        index=$(($index+1))
    done
done

chosen=$(echo -e "${configs[@]}" | 
    column -t -o " | " -N "Index,Left,Right" | 
    rofi -dmenu -show -p 'Select display configuration' |
    awk '{ print $1 }')

echo $chosen
chosen_display1=$(echo ${configs[$chosen]} | awk '{ print $2 }')
chosen_display2=$(echo ${configs[$chosen]} | awk -F ' ' '{ print $3 }')
echo "$chosen_display1 $chosen_display2"
if [ $chosen_display2 != "\n" ]; then
    cmd="xrandr --output $chosen_display1 --left-of $chosen_display2"
else
    cmd="xrandr --output $chosen_display1 --left-of $chosen_display2"
fi
