#!/bin/nu
# nu-ify ffprobe and provide some extra utilities

# Get video info in table form from ffmpeg
export def info [fname: string] -> table {
    ffprobe -v quiet -print_format json -show_format -show_streams $fname | from json
}

# Aspect ratio informtation and landscape bool
export def aspect-ratio [fname: string] {
    info $fname | 
        get streams | 
        select width height | 
        insert ratio {|it| $it.width / $it.height} | 
        insert landscape {|it| $it.ratio > 1}
}

# Get landscape / portrait orientation
export def orientation [fname: string] {
    aspect-ratio $fname | get landscape
}