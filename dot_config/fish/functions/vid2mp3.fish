function vid2mp3 --description 'Extract audio from video as MP3'
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: vid2mp3 <input_video> <output_basename>"
        echo "Example: vid2mp3 movie.mp4 soundtrack (saves soundtrack.mp3)"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: vid2mp3 <input_video> <output_basename>" >&2
        return 1
    end

    ffmpeg -i $argv[1] -vn -acodec libmp3lame -q:a 2 $argv[2].mp3
end
