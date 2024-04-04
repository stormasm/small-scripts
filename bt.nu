#!/home/marchall/.cargo/bin/nu

# List bluetooth devices and connection status
export def list [] {
    let connected = (connected)
    bluetoothctl devices | 
        split row -r '\n' | 
        each {|it| $it | parse "{device} {address} {name}"} |
        flatten | 
        select address name | 
        insert connected {|x| (not ($connected | is-empty)) and ($x.address == (connected | get address.0))}
}

# Output connected device 
export def connected [] {
    bluetoothctl devices Connected | 
        str trim | 
        parse "{device} {address} {name}"
}

# Wrapper for `bluetoothctl disconnect`
export def disconnect [] {
    if (connected | length) > 0 {
        let output = (bluetoothctl disconnect | complete)
        if $output.exit_code != 0 {
            print "Disconnect failed"
        }
    }
}

# Display prompt to connect to device
export def connect [] {
    let choice = (list | input list -d name)
    if ($choice | is-empty) { return }

    let connected = (connected)
    if $choice.address == ($connected | get address.0) and (not ($connected | is-empty)) { 
        print $"Already connected to ($choice.name)... exiting"
        return
    }
    print $"Connecting to: ($choice.name) \(($choice.address)\)"
    let connection_status = (bluetoothctl connect $choice.address | complete)
    if $connection_status.exit_code != 0 { 
        print "Connection unsuccessful. Output:"
        print $"\n(ansi red_bold)($connection_status.stdout)"
    }
}

export def main [] {
    list
}
