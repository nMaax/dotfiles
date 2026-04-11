function jpg2png
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
