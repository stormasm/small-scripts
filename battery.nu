#!/bin/env nu
# battery.nu

export def "battery info" [
  --interface (-i): string = "BAT0" # Battery interface
] {
  open $"/sys/class/power_supply/($interface)/uevent" | 
    from csv -n --separator '=' | 
    update column1 {
      $in | 
      str replace -a "POWER_SUPPLY_" "" | 
      str downcase
    } | 
    transpose -r |
    into record
}

export def "battery level" [] {
  battery info | get capacity
}

export def "battery notify" [] {
  notify-send $"Battery: (battery level)%"
}

export def main [] {
  battery info
}
