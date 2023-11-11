#!/bin/env nu
# battery.nu
# Get battery info

export def main [
  --interface (-i): string = "BAT0" # Battery interface
  --long (-l) # All fields
] {
  let info = (open $"/sys/class/power_supply/($interface)/uevent" | 
    from csv -n --separator '=' | 
    update column1 {
      $in | 
      str replace -a "POWER_SUPPLY_" "" | 
      str downcase
    } | 
    transpose -r |
    into record |
    each { $in | str trim } | 
    insert charging { $in.status == "Charging" })
  if $long { $info } else { $info | select name charging capacity }
}

export def "battery level" [] {
  battery info | get capacity
}

export def "battery notify" [] {
  notify-send $"Battery: (battery level)%"
}
