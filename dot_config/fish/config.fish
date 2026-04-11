source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
    # Only run fastfetch if the terminal width is greater than 80 characters
    if test "$COLUMNS" -gt 80
        fastfetch
    end
end

# Some useful variables
set -gx TERMINAL ghostty
set -gx EDITOR vim
set -gx SUDO_EDITOR vim
set -gx BROWSER zen-browser
set -gx PAGER bat

# Initialize starship and zoxide for better experience
if status is-interactive
    starship init fish | source
    zoxide init fish | source
end
