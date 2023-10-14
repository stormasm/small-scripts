#!/bin/env nu
# utils.nu

# Print 'not implemented' message
export def not-implemented [
  item: string # Item not implemented
] { 
  print $"(ansi red)Note:(ansi reset) (ansi attr_italic)($item)(ansi reset) (ansi red)not implemented(ansi reset)" 
} 

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
export def venumerate [] {
  zip 1..($in | length) | each { $"($in.1) - ($in.0)" } 
}