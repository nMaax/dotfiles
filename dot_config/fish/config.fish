source /usr/share/cachyos-fish-config/cachyos-config.fish

# The CachyOS snippet above unconditionally redefines fish_greeting to just call
# fastfetch. conf.d loads before config.fish, so overriding it there (see
# conf.d/fastfetch-resize-clear.fish) gets clobbered by this source line; the
# override has to live here, after it, to actually win.
function fish_greeting
    if test "$COLUMNS" -gt $__fastfetch_min_cols; and test "$LINES" -gt $__fastfetch_min_lines
        set -g __fastfetch_shown 1
        set -g __fastfetch_is_narrow 0
        fastfetch
    else
        set -g __fastfetch_shown 0
        set -g __fastfetch_is_narrow 1
    end
end

# Some useful variables
if not set -q TERMINAL
    set -l _cfg_dir "$HOME/.config"
    set -q XDG_CONFIG_HOME; and test -n "$XDG_CONFIG_HOME"; and set _cfg_dir "$XDG_CONFIG_HOME"
    if test -r "$_cfg_dir/default-terminal"; and read -l _term < "$_cfg_dir/default-terminal"; and test -n "$_term"
        set -gx TERMINAL $_term
    else
        set -gx TERMINAL ghostty
    end
end
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
