function svg2png
    for file in $argv
        if test -f $file
            set name (string replace -r '\.[sS][vV][gG]$' '' $file)
            # -background none preserves transparency
            # -density 300 ensures a crisp render
            magick -background none -density 300 $file "$name.png"
            and echo "Converted $file to $name.png"
        end
    end
end
