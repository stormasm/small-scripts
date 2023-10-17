#!/bin/env nu
# wifi.nu

# Get wifi networks
def get-networks [] {
    nmcli -f BSSID,SSID,MODE,RATE,SIGNAL,BARS,SECURITY,CHAN,IN-USE device wifi list | 
        str trim | 
        from ssv -m 2 | 
        rename -b {str replace -a '-' '' | str downcase} | 
        insert wpa {$in | str contains WPA security | get security}
}

# Get current config
export def config [] {
    nmcli device show | from ssv -n | transpose -r | rename -b {str trim -c ':' | str downcase}
}

# Connect to wifi and optionally save to pass store
# TODO: Check if password is already in store
export def connect [
    --no-save (-n) # Don't save password to pass store
] {
    let networks = (get-networks)
    let choice = ($networks | get SSID | input list)
    let choice = ($networks | where ssid == $choice)
    if ($choice | is-empty) { print "No choice"; return }
    if ($choice | first | get wpa) {
        let password = (input -s "Password: ")
        nmcli device wifi connect $choice password $password
        if not $no_save {
            echo $password | pass insert $"wifi/($choice)" --echo
        }
    } else {
        nmcli device wifi connect $choice
    }
}

# Disconnect from wifi
export def disconnect [] {
    nmcli device disconnect (config | get "general.device")
}

# Get wifi networks
export def main [] {
    get-networks
}