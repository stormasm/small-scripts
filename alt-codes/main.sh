#!/bin/bash

# if [ -f "./config.sh" ]; then
#     source ./config.sh
# fi

SYMBOL_PPATH=${SYMBOL_PPATH:-"/bin/python"}
echo $SYMBOL_PPATH

sqlite3 symbols.db "SELECT Unicode, Alt_Code as int, Description 
    FROM symbols 
    WHERE Alt_Code != 'None'" | 
    column -ts '|' -o ' | ' | 
    rofi -show -dmenu -i -p 'Select symbol' | 
    awk '{print $1}' | 
    xclip -sel clip
