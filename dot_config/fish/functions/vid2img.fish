function vid2img --description "Extract a frame from a video"
    # Check if input file is provided
    if test (count $argv) -lt 1
        echo "Usage: vid2img <video_file> [timestamp]"
        echo "Example: vid2img movie.mp4 00:02:30"
        return 1
    end

    set -l input $argv[1]
    set -l time "00:00:00"
    
    # Use second argument for time if provided
    if test (count $argv) -gt 1
        set time $argv[2]
    end

    # Define output filename based on input name
    set -l output (string replace -r '\.[^\.]+$' '' $input)"_frame.jpg"

    # Execute ffmpeg
    ffmpeg -ss $time -i $input -vframes 1 -q:v 2 $output

    if test $status -eq 0
        echo "Successfully saved frame to $output"
    else
        echo "Error: Frame extraction failed."
    end
end
