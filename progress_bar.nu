#!/bin/env nu 
# progress_bar.nu

use std repeat


def print-bar [on, off, max, count] {
  print -n $"[($on | repeat $count | append ($off | repeat ($max - $count)) | str join)]\r"
}

# Progress bar
export def main [
  --max (-m): int = 10 # Maximum width in chars
  --inc (-i): int = 1 # Increment
] {
  mut count = 0
  let min = 0
  let on = '*'
  let off = '-'

  print-bar $on $off $max $count
  mut inp = (input listen --types [key])
  while $inp.code not-in ['esc', 'enter'] { 
    if $inp.code == 'right' { $count = ([($count + $inc), $max] | math min) }
    if $inp.code == 'left' { $count = ([($count - $inc), $min] | math max) }
    print-bar $on $off $max $count
    $inp = (input listen --types [key]) 
  }
  ($count / $max)
}
