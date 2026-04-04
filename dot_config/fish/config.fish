source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
    # Only run fastfetch if the terminal width is greater than 80 characters
    if test "$COLUMNS" -gt 80
        fastfetch
    end
end

set -gx TERMINAL ghostty
set -gx EDITOR vim
set -gx SUDO_EDITOR vim
set -gx BROWSER zen-browser
set -gx PAGER bat

if status is-interactive
    # Start the ssh agent and add your key
    keychain --eval --quiet .ssh/id_ed25519 | source
    # Start starship for a eye-candy terminal interaction
    starship init fish | source
end
