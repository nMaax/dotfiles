function vid2mp3 --description 'Extract audio from video as MP3'
    ffmpeg -i $argv[1] -vn -acodec libmp3lame -q:a 2 $argv[2].mp3
end
