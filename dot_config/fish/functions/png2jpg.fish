function png2jpg -d "Convert PNG images to JPG"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: png2jpg <file1.png> [file2.png ...]"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: png2jpg <file1.png> [file2.png ...]" >&2
        return 1
    end

    for file in $argv
        if test -f $file
            set name (string replace -r '\.[pP][nN][gG]$' '' $file)
            # JPGs don't support transparency, so we flatten against a white background
            magick $file -flatten "$name.jpg"
            and echo "Converted $file to $name.jpg"
        else
            echo "Error: $file not found."
        end
    end
end
