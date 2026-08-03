function svg2png -d "Convert SVG images to PNG"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: svg2png <file1.svg> [file2.svg ...]"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: svg2png <file1.svg> [file2.svg ...]" >&2
        return 1
    end

    for file in $argv
        if test -f $file
            set name (string replace -r '\.[sS][vV][gG]$' '' $file)
            # -background none preserves transparency
            # -density 300 ensures a crisp render
            magick -background none -density 300 $file "$name.png"
            and echo "Converted $file to $name.png"
        else
            echo "Error: $file not found."
        end
    end
end
