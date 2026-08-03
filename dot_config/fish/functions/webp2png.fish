function webp2png --description 'Convert WebP images to PNG'
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: webp2png <file1.webp> [file2.webp ...]"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: webp2png <file1.webp> [file2.webp ...]" >&2
        return 1
    end

    for file in $argv
        if test -f $file
            set -l output (string replace -r '\.webp$' '.png' $file)
            magick $file $output
            echo "Converted: $file -> $output"
        else
            echo "Error: $file not found."
        end
    end
end
