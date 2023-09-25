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
    transpose -r
}

export def "battery level" [] {
  battery info | get capacity | first
}

export def "battery notify" [] {
  notify-send $"Battery: $(battery level)%"
}

export def main [] {
  battery info
}
