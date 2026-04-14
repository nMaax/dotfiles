function ai_upscale -d "Upscale an image using GPU-accelerated Real-ESRGAN"
    if test (count $argv) -eq 0
        echo "Usage: ai_upscale <input_file> [scale_factor]"
        echo "Example: ai_upscale photo.jpg 4"
        return 1
    end

    set input $argv[1]

    # Default scale is 4x if a second argument isn't provided
    if test (count $argv) -ge 2
        set scale $argv[2]
    else
        set scale 4
    end

    set output "upscaled_"$scale"x_"(basename $input)

    echo "Upscaling $input by $scale"x" using your GPU..."

    # The core command utilizing the Vulkan API for GPU acceleration
    realesrgan-ncnn-vulkan -i $input -o $output -s $scale

    if test $status -eq 0
        echo "Done. Saved as $output"
    else
        echo "Error: Upscaling failed. Make sure 'realesrgan-ncnn-vulkan' is installed and your GPU is accessible."
    end
end
