function vid-shrink -d "Shrink a video's file size via H.265 re-encode"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: vid-shrink <input_video> <output_video>"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: vid-shrink <input_video> <output_video>" >&2
        return 1
    end

    ffmpeg -i $argv[1] -vcodec libx265 -crf 28 $argv[2]
end
