#!/bin/env nu 
# progress_bar.nu

export def main [] {
  mut count = 0
  let inc = 1
  let max = 10
  let min = 0
  let on = '*'
  let off = '-'

  mut inp = (input listen --types [key])
  while $inp.code != 'esc' { 
    ^echo -e '\033[1K'
    print -n $'[($on | repeat $count | append ($off | repeat ($max - $count)) | str join)]'
    $inp = (input listen --types [key]) 
    if $inp.code == 'right' { $count = ([($count + $inc), $max] | math min) }
    if $inp.code == 'left' { $count = ([($count - $inc), $min] | math max) }
  }
}
