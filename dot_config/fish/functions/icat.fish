function icat
    if test (count $argv) -eq 0
        echo "Usage: icat <image_path>"
        return 1
    end

    # Use kitty's builtin icat kitten
    # --hold keeps the image visible after the process finishes
    # --align left ensures standard terminal behavior
    kitty +kitten icat --hold --align left $argv
end
