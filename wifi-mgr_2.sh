#!/bin/bash

STATION="wlan0"

# Pipe wifi networks to rofi
connect() {
    networks_info=$(iwctl station $STATION get-networks | 
        awk '{ if (NR > 5) print $0 }')
    
    networks=$(echo "${networks_info}" | awk '{ print $1 }')
    # securities=$( | readarray)
    readarray -t networks_list < <(echo "${networks_info}" | awk '{ print $1 }')
    readarray -t securities < <(echo "${networks_info}" | awk '{ print $2 }')
    network_choice=$(echo "${networks}" | 
        nl | 
        rofi -dmenu -show -i -p 'Select network' | 
        awk '{ print $1-1 }'
    )
    security=${securities[$network_choice]}
    if [[ "$security" -eq "psk" ]]; then
        password=$(rofi -dmenu -show -p "Enter password")
        connect_status=$(iwctl station $STATION connect $network_choice --passphrase="$password")
    else
        connect_status=$(iwctl station $STATION connect $network_choice)
    fi

    if [[ "$connect_status" -ne "" ]]; then
        notify-send "WiFi Manager" "Failed to connect to: $network_choice"
        main_menu
    else
        notify-send "WiFi Manager" "Connected to: $network_choice"
    fi
}

disconnect() {
    iwctl station $STATION disconnect
    notify-send "WiFi Manager" "Disconnecting from WiFi network"
}

exit_rofi() {
    exit 0
}

main_menu() {
    declare -A rofi_options 
    rofi_options["Connect"]="connect"
    rofi_options["Disconnect"]="disconnect"
    rofi_options["Exit"]="exit_rofi"

    args=$(echo ${!rofi_options[@]} | 
        awk '{ for (i = 1; i < NF + 1; i++) print $i }')
    chosen=$(echo -e "$args" | rofi -dmenu -i -show -p "Choose option")
    ${rofi_options[$chosen]}
}

# main_menu
connect
