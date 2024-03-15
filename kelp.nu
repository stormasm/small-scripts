#!/bin/env nu

# Select kitty theme 
export def change-theme [] {
  let theme = (
    ls ~/.config/kitty/kitty-themes/themes/ | 
      get name | 
      path basename | 
      each {str replace '.conf' ''} | 
      input list --fuzzy
  )
  ln -sf $"($env.XDG_CONFIG_HOME)/kitty-themes/themes/($theme).conf" $"($env.XDG_CONFIG_HOME)/kitty/theme.conf"
}
