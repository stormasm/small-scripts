#!/bin/bash
# wifi-mgr.sh

notify-send "Getting Wi-Fi networks..."

networks=$(nmcli --fields 'SECURITY,SSID' device wifi list)

network=$(echo -e "$networks" | uniq -u | rofi -dmenu -i -selected-row 1 -p "WiFi")
