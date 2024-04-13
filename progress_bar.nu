#!/bin/env nu 
# progress_bar.nu

use std repeat


export def print-bar [on, off, max, count, show_value, max_disp_value, min_disp_value, percent] {
  let $append_value = if $show_value {
    let max_value = if ($max_disp_value | is-not-empty) { $max_disp_value } else { $max }
    let min_value = if ($min_disp_value | is-not-empty) { $min_disp_value } else { 0 }
    if $percent {
      $" \((($count / $max | math round -p 2) * 100)%)"
    } else {
      $" \((($max_value - $min_value) * ($count / ($max - $min)) + $min_value | math round -p 3))"
    }
  } else {
    ""
  }
  print -n $"[($on | repeat $count | append ($off | repeat ($max - $count)) | str join)]($append_value)\r"
}

# Progress bar
export def main [
  --max (-m): int = 10 # Maximum width in chars
  --inc (-i): int = 1 # Increment
  --show-value (-s) # Show value to side of bar
  --max-disp-value (-M): int # Max value to display
  --min-disp-value (-m): int # Min value to display
  --percent (-p) # Show value as percent
] {
  mut count = 0
  let min = 0
  let on = '*'
  let off = '-'

  print-bar $on $off $max $count $show_value $max_disp_value $min_disp_value $percent
  mut inp = (input listen --types [key])
  while $inp.code not-in ['esc', 'enter'] { 
    if $inp.code == 'right' { $count = ([($count + $inc), $max] | math min) }
    if $inp.code == 'left' { $count = ([($count - $inc), $min] | math max) }
    print-bar $on $off $max $count $show_value $max_disp_value $min_disp_value $percent
    $inp = (input listen --types [key]) 
  }
  ($count / $max)
}
