source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
    # Only run fastfetch if the terminal width is greater than 80 characters
    if test "$COLUMNS" -gt 80
        fastfetch
    end
end

if status is-interactive
    # Start the ssh agent and add your key
    keychain --eval --quiet .ssh/id_ed25519 | source
    # Start starship for a eye-candy terminal interaction
    starship init fish | source
end
