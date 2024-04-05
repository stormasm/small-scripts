#!/bin/env nu
# disp.nu

# Get display info via xrandr
export def info [] {
  xrandr --verbose | 
    lines | 
    find -r '(Brightness)|( connected)' | 
    window 2 | each { |d| 
        $d.0 | 
          parse --regex '^(?<name>\w+) (?<connection>connected|disconnected) (?<rank>\w+) (?<width>[0-9]+)x(?<height>[0-9]+)\+(?<xoffset>[0-9]+)\+(?<yoffset>[0-9]+) (?<rest>.*)$' |
          get 0 |
          merge ($d.1 | str trim | parse 'Brightness: {brightness}' | get -i 0 | default 1.0)
      } |
    update brightness { |row| $row.brightness | into float }
}

export def main [] {
  info
}
