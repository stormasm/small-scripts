#!/bin/env nu
# vol.nu

def get-vol [
  --controller (-c): string = "Master" # Controller
] {
  amixer sget $controller | 
    str trim | 
    split row -r '\n' | 
    last 2 | 
    split column -r '[\[\]]' | 
    select column2 column4 | 
    rename volume status | 
    merge ([left right] | wrap index) |
    update volume {$in | str trim -c "%" | into int}
}

# Notify current volume
export def notify [
  --side (-s): string = "both" # Both, right, left
] {
  if not ($side in [both right left]) {
    return
  }
  let side = if ($side == "both") { "right" } else { $side }
  let vol = (get-vol | where index == $side) 
  notify-send $"Volume (($vol.status.0)): ($vol.volume.0)%" -r 45
}

# Set volume
export def set [
  value: int # Volume percent
  --controller (-c): string = "Master" # Controller
  --silent (-s) # Don't notify new values
] {
  let output = (amixer set $controller $"($value)%" | complete)
  if not $silent {
    notify
  }
}

# Increment volume
export def inc [
  value: int = 5 # Increment value
  --controller (-c): string = "Master" # Controller
  --side (-s): string = "both" # Both, right, left
] {
  if not ($side in [both right left]) {
    return
  }
  let side = if ($side == "both") { "right" } else { $side }
  let vol = (get-vol --controller $controller | 
    where index == $side | 
    get volume |
    first
  )
  set ($vol + $value) --controller $controller
}

# Decrement volume
export def dec [
  value: int = 5 # Increment value
  --controller (-c): string = "Master" # Controller
  --side (-s): string = "both" # Both, right, left
] {
  inc (-1 * $value) --controller $controller --side $side
}

# Mute volume
export def off [
  --controller (-c): string = "Master" # Controller
  --silent (-s) # Don't notify new values
] {
  let output = (amixer sset $controller off | complete)
  if not $silent {
    notify
  }
}

# Turn volume on
export def on [
  --controller (-c): string = "Master" # Controller
  --silent (-s) # Don't notify new values
] {
  let output = (amixer sset $controller on | complete)
  if not $silent {
    notify
  }
}

# Toggle volume
export def toggle [
  --controller (-c): string = "Master" # Controller
  --silent (-s) # Don't notify new values
] {
  let output = (amixer sset $controller toggle | complete)
  if not $silent {
    notify
  }
}

# Get volume
export def main [] {
  get-vol
}
