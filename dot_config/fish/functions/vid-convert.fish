function vid-convert
    ffmpeg -i $argv[1] -c:v libx264 -crf 23 -c:a aac -pix_fmt yuv420p $argv[2]
end
