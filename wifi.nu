#!/bin/env nu
# wifi.nu

const PASSWORD_STORE_DIR = "~/.password-store"
const WIFI_PASSWORD_DIR = "wifi"

# Get wifi networks
export def get-networks [] {
    let config = (config)
    nmcli -f BSSID,SSID,MODE,RATE,SIGNAL,BARS,SECURITY,CHAN device wifi list | 
        str trim | 
        from ssv -m 2 | 
        rename -b {str replace -a '-' '' | str downcase} | 
        insert active {|row| $row.ssid == $config.general_connection } |
        insert wpa {|row| ($row.security | str contains 'WPA') } |
        insert name_fmt { |row| 
          $'($row.ssid) (if $row.wpa { $"\((ansi red_bold)secure(ansi reset))" }) (if $row.active { $"\((ansi green_bold)active(ansi reset))" })' 
        } |
        uniq-by ssid
}

# Get current config
export def config [] {
    nmcli device show | 
      from ssv -n | 
      transpose -r | 
      rename -b {str trim -c ':' | str downcase | str replace '.' '_'} | 
      into record
}

# Connect to wifi and optionally save to pass store
export def connect [] {
  let networks = (get-networks)
  let choice = ($networks | input list -fd name_fmt)
  if ($choice | is-empty) { return }
  if $choice.active { print $"($choice.ssid) already active"; return }

  if not ($choice.wpa) { 
    let connection_status = (nmcli device wifi connect $choice.ssid | complete) 
    if $connection_status.stdout == 0 {
      print $"(ansi green)Connected to ($choice.ssid)(ansi reset)"
    } else {
      print $"(ansi red)Failed to connect to ($choice.ssid)(ansi reset)"
    }
    return
  }

  mut password = if not (ls ($PASSWORD_STORE_DIR | path join $WIFI_PASSWORD_DIR) -s | where name == $"($choice.ssid).gpg" | is-empty) {
    print "Pulling password from store"
    (pass show $'wifi/($choice.ssid)')
  } else {
    (input "Enter password: ")
  }

  while not (enter-password $choice $password) {
    $password = (input "Enter password again: ")
  }
  let pass_insert_status = (echo $password | pass insert $"($WIFI_PASSWORD_DIR)/($choice.ssid)" --echo | complete)
  if $pass_insert_status.exit_code == 0 { 
    print $"Successfully inserted password into ($WIFI_PASSWORD_DIR)/($choice.ssid)" 
  } else {
    print "(ansi red)Failed to insert password into store(ansi reset)"
  }
  print $"(ansi green)Connected to ($choice.ssid)(ansi reset)"
}

# Connect to password-protected network using nmcli 
def enter-password [
  choice: record
  password: string
] -> bool {
  let connection_status = (nmcli device wifi connect ($choice.ssid) password $password | complete)
  if $connection_status.exit_code == 0 { 
    true
  } else {
    print $"(ansi red)Password incorrect or outdated(ansi reset)"
    false
  }
}

# Disconnect from wifi
export def disconnect [] {
    nmcli device disconnect (config | get general_device)
}

# Get wifi networks
export def main [] {
    get-networks
}

# Show wifi connection info
export def show [] {
  nmcli device wifi show
}
