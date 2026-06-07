source /usr/share/cachyos-fish-config/cachyos-config.fish

set -g __fastfetch_min_cols 80
set -g __fastfetch_shown 0
set -g __fastfetch_is_narrow 0

function fish_greeting
    # Only run fastfetch if the terminal width is greater than 80 characters
    if test "$COLUMNS" -gt $__fastfetch_min_cols
        set -g __fastfetch_shown 1
        set -g __fastfetch_is_narrow 0
        fastfetch
    else
        set -g __fastfetch_shown 0
        set -g __fastfetch_is_narrow 1
    end
end

function __auto_clear_fastfetch_on_resize --on-variable COLUMNS
    if not status is-interactive
        return
    end

    if not set -q __fastfetch_shown
        set -g __fastfetch_shown 0
    end

    if not set -q __fastfetch_is_narrow
        set -g __fastfetch_is_narrow 0
    end

    if test "$__fastfetch_shown" -ne 1
        return
    end

    if test "$COLUMNS" -le $__fastfetch_min_cols
        if test "$__fastfetch_is_narrow" -ne 1
            clear
            set -g __fastfetch_is_narrow 1
        end
    else
        set -g __fastfetch_is_narrow 0
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
    direnv hook fish | source
end
