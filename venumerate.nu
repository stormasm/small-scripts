#!/bin/env nu
# Visually enumerate

# Visually enumerate 
# 
# Example:
# ➜ ls | get name | venumerate | first 5
# ╭───┬───────────────────────────╮
# │ 0 │ 1 - README.md             │
# │ 1 │ 2 - alt-codes             │
# │ 2 │ 3 - battery.nu            │
# │ 3 │ 4 - brightness            │
# │ 4 │ 5 - brightness-control.sh │
# ╰───┴───────────────────────────╯
export def main [] {
  zip 1..($in | length) | each { $"($in.1) - ($in.0)" } 
}
