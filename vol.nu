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
export def "vol notify" [
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
export def "vol set" [
  value: int # Volume percent
  --controller (-c): string = "Master" # Controller
  --silent # Don't notify new values
] {
  let output = (amixer set $controller $"($value)%" | complete)
  if not $silent {
    vol notify
  }
}

# Increment volume
export def "vol inc" [
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
  vol set ($vol + $value) --controller $controller
}

# Decrement volume
export def "vol dec" [
  value: int = 5 # Increment value
  --controller (-c): string = "Master" # Controller
  --side (-s): string = "both" # Both, right, left
] {
  vol inc (-1 * $value) --controller $controller --side $side
}

# Mute volume
export def "vol mute" [
  --controller (-c): string = "Master" # Controller
  --silent # Don't notify new values
] {
  let output = (amixer sset $controller off | complete)
  if not $silent {
    vol notify
  }
}

# Toggle volume
export def "vol toggle" [
  --controller (-c): string = "Master" # Controller
  --silent # Don't notify new values
] {
  let output = (amixer sset $controller toggle | complete)
  if not $silent {
    vol notify
  }
}

# Get volume
export def main [] {
  get-vol
}
