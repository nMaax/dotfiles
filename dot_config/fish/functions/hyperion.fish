function hyperion
    # Change background color to PoliTo Deep Blue when connected to Hyperion
    printf "\e]11;#1a0b2e\a"
    ssh hyperion
    # Revert the color back to a default black (doesnt affect other terminal sessions)
    printf "\e]11;#000000\a"
end
