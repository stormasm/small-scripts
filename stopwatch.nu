#!/bin/env nu
# stopwatch.nu

export def main [] {
  let start = (date now)
  while true { ^printf '%s\r' $"((date now) - $start | format duration sec)" }
}
