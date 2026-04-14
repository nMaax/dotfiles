function img_effect -d "Apply center crop or effects to an image"
    if test (count $argv) -lt 2
        echo "Usage: img_effect <effect> <input_file> [crop_dimensions]"
        echo "Effects: crop (requires dimensions like 500x500), blur, frosted, fisheye"
        return 1
    end

    set effect $argv[1]
    set input $argv[2]
    set output "edited_"(basename $input)

    switch $effect
        case crop
            if test (count $argv) -lt 3
                echo "Error: Crop requires dimensions (e.g., img_effect crop image.jpg 800x800)"
                return 1
            end
            set dim $argv[3]
            magick $input -gravity center -crop $dim+0+0 +repage $output
            echo "Center cropped to $dim: $output"

        case blur
            # 0x8 defines the radius and sigma of the Gaussian blur
            magick $input -blur 0x8 $output
            echo "Blur applied: $output"

        case frosted
            # Spreads pixels randomly, then slightly blurs them to mimic frosted glass
            magick $input -spread 5 -blur 0x2 $output
            echo "Frosted effect applied: $output"

        case fisheye
            # Uses barrel distortion to create a fisheye lens look
            magick $input -distort Barrel "0.0 0.0 0.5 1.0" $output
            echo "Fisheye effect applied: $output"

        case '*'
            echo "Unknown effect. Use: crop, blur, frosted, fisheye."
            return 1
    end
end
