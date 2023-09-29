#!/home/marchall/.cargo/bin/nu

# List bluetooth devices and connection status
export def "bt list" [] {
    let connected = bt connected
    bluetoothctl devices | 
        split row -r '\n' | 
        each {|it| $it | parse "{device} {address} {name}"} |
        flatten | 
        select address name | 
        insert connected {|x| (not ($connected | is-empty)) and ($x.address == (bt connected | get address.0))}
}

# Output connected device 
export def "bt connected" [] {
    bluetoothctl devices Connected | 
        str trim | 
        parse "{device} {address} {name}"
}

# Wrapper for `bluetoothctl disconnect`
export def "bt disconnect" [] {
    if (bt connected | length) > 0 {
        let output = (bluetoothctl disconnect | complete)
        if $output.exit_code != 0 {
            print "Disconnect failed"
        }
    }
}

# Display prompt to connect to device
export def "bt connect" [] {
    let options = (bt list)
    let choice = ($options.name | input list)
    let address = ($options | where name == $choice | get address.0)
    let connected = bt connected
    if $address == (not ($connected | is-empty)) and ($connected | get address.0) { 
        print $"Already conncted to ($choice)... exiting"
        return
    }
    print $"Connnecting to: ($choice) \(($address)\)"
    let connection_status = (bluetoothctl connect $address | complete)
    if $connection_status.exit_code != 0 { 
        print "Connection unsuccessful. Output:"
        print $"\n(ansi red_bold)($connection_status.stdout)"
    }
}

export def main [] {
    bt list
}
