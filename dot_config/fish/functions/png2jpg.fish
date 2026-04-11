function png2jpg
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
