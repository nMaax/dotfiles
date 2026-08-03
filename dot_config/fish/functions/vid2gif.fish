function vid2gif -d "Convert a video to a palette-optimized GIF via ffmpeg"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: vid2gif <input_video> <output.gif>"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: vid2gif <input_video> <output.gif>" >&2
        return 1
    end

    set val "fps=15,scale=720:-1:flags=lanczos"
    ffmpeg -i $argv[1] -vf "$val,palettegen" -y /tmp/palette.png
    ffmpeg -i $argv[1] -i /tmp/palette.png -lavfi "$val [x]; [x][1:v] paletteuse" $argv[2]
end
