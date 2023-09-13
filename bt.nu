#!/home/marchall/.cargo/bin/nu

# List bluetooth devices and connection status
export def list [] {
    let connected = connected
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

# Display prompt to connect to device
export def connect [] {
    let options = (list)
    let choice = ($options.name | input list)
    let address = ($options | where name == $choice | get address.0)
    let connected = connected
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