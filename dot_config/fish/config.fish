# *** CACHYOS CONFIGS ***s
source /usr/share/cachyos-fish-config/cachyos-config.fish

# *** FUNCTIONS ***
function fish_greeting
    # Only run fastfetch if the terminal width is greater than 80 characters
    if test "$COLUMNS" -gt 80
        fastfetch
    end
end

function hyperion
    # Change background color to PoliTo Deep Blue when connected to Hyperion
    printf "\e]11;#1a0b2e\a"
    ssh hyperion
    # Revert the color back to a default black (doesnt affect other terminal sessions)
    printf "\e]11;#000000\a"
end

# *** INTERACTIVE-ONLY CONFIGS  ***
if status is-interactive
    # Start the ssh agent and add your key
    keychain --eval --quiet .ssh/id_ed25519 | source
    # Start starship for a eye-candy terminal interaction
    starship init fish | source
end

