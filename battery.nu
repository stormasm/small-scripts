#!/bin/env nu
# battery.nu
# Get battery info

export def main [
  --interface (-i): string = "BAT0" # Battery interface
  --long (-l) # All fields
] {
  let info = (get-info -i $interface)
  if $long { $info } else { $info | select name charging capacity }
}

export def get-info [
  --interface (-i): string = "BAT0" # Battery interface
] {
  open $"/sys/class/power_supply/($interface)/uevent" | 
    from csv -n --separator '=' | 
    update column1 { str replace -a "POWER_SUPPLY_" "" | str snake-case } | 
    transpose -r | 
    into record | 
    each { str trim } | 
    insert charging { |value| $value.status == "Charging" }
}

export def level [] {
  get-info | get capacity
}

export def notify [] {
  notify-send $"Battery: (level)%"
}
