let brightnesses = (xrandr --verbose | find "brightness" | each { $in | split row ' ' | last })
let displays = (
  xrandr --verbose | 
    lines | 
    find " connected" | 
    split column ' ' | 
    select column1 column3 column4 | 
    rename display primary resolution | 
    insert brightness $brightnesses | 
    flatten
)