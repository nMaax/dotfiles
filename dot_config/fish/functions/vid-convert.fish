function vid-convert -d "Re-encode a video to H.264/AAC via ffmpeg"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: vid-convert <input_video> <output_video>"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: vid-convert <input_video> <output_video>" >&2
        return 1
    end

    ffmpeg -i $argv[1] -c:v libx264 -crf 23 -c:a aac -pix_fmt yuv420p $argv[2]
end
