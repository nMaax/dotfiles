function webp2png --description 'Convert WebP images to PNG'
    if count $argv >/dev/null
        for file in $argv
            if test -f $file
                set -l output (string replace -r '\.webp$' '.png' $file)
                magick $file $output
                echo "Converted: $file -> $output"
            else
                echo "Error: $file not found."
            end
        end
    else
        echo "Usage: webp2png image1.webp image2.webp ..."
    end
end
