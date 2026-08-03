function jpg2png -d "Convert JPG/JPEG images to PNG"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: jpg2png <file1.jpg> [file2.jpg ...]"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: jpg2png <file1.jpg> [file2.jpg ...]" >&2
        return 1
    end

    for file in $argv
        if test -f $file
            set name (string replace -r '\.[jJ][pP][eE]?[gG]$' '' $file)
            magick $file "$name.png"
            and echo "Converted $file to $name.png"
        else
            echo "Error: $file not found."
        end
    end
end
