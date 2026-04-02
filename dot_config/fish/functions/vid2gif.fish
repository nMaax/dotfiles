function vid2gif
    set val "fps=15,scale=720:-1:flags=lanczos"
    ffmpeg -i $argv[1] -vf "$val,palettegen" -y /tmp/palette.png
    ffmpeg -i $argv[1] -i /tmp/palette.png -lavfi "$val [x]; [x][1:v] paletteuse" $argv[2]
end
