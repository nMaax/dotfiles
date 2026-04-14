function lanczos_upscale -d "Upscale an image by 200% using Lanczos filtering"
    if test (count $argv) -eq 0
        echo "Usage: img_upscale <input_file>"
        return 1
    end

    set input $argv[1]
    set output "upscaled_"(basename $input)

    echo "Upscaling $input by 2x..."
    magick $input -filter Lanczos -resize 200% $output
    echo "Done. Saved as $output"
end
