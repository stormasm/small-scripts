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
export def "wifi config" [] {
    nmcli device show | from ssv -n | transpose -r | rename -b {str trim -c ':' | str downcase}
}

# Connect to wifi
export def "wifi connect" [] {
    let networks = (get-networks)
    let choice = ($networks | get SSID | input list)
    if ($networks | where ssid == $choice | first | get wpa) {
        let password = (input -s "Password: ")
        nmcli device wifi connect $choice password $password
    } else {
        nmcli device wifi connect $choice
    }
}

# Disconnect from wifi
export def "wifi disconnect" [] {
    nmcli device disconnect (wifi config | get "general.device")
}

# Get wifi networks
export def main [] {
    get-networks
}