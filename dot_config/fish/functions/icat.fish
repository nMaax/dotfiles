function icat -d "Display an image inline in the terminal via kitty's icat kitten"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: icat <image_path>"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: icat <image_path>" >&2
        return 1
    end

    # Use kitty's builtin icat kitten
    # --hold keeps the image visible after the process finishes
    # --align left ensures standard terminal behavior
    kitty +kitten icat --hold --align left $argv
end
