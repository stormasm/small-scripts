#!/bin/env nu
# disp.nu

use std repeat

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

export def display-options [] {
  # xrandr --output eDP1 --output HDMI2 --mode 1920x1080 --right-of eDP1
  # let monitors = [eDP1 HDMI1 HDMI3] 
  let monitors = (xrandr -q | find ' connected' | split column ' ' | get column1)

  xrandr ($"{($monitors | str join ',')}" | 
    repeat ($monitors | length) | 
    str join '\,' | 
    str expand | 
    split column ',' |
    insert uniq { |row| ($row | str trim | transpose --ignore-titles) | uniq | get column0 } | 
    uniq-by uniq | 
    insert cmd { |row|
      mut cmd = [$"--output ($row.uniq.0)"]
      for duo in ($row.uniq | window 2) {
        $cmd = ($cmd | append $"--output ($duo.1) --right-of ($duo.0)") 
      }
      $cmd | str join ' '
    } | 
    insert fmt { |row| $"| ($row.uniq | str join ' | ') |" } | 
    insert n_monitors { |row| $row.uniq | length } | 
    sort-by n_monitors | 
    input list -d fmt | 
    get cmd
  )
}
