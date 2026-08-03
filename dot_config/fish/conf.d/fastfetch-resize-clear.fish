set -g __fastfetch_min_cols 80
set -g __fastfetch_min_lines 20
set -g __fastfetch_shown 0
set -g __fastfetch_is_narrow 0

function __fastfetch_check_resize
    if not status is-interactive
        return
    end

    if test "$__fastfetch_shown" -ne 1
        return
    end

    if test "$COLUMNS" -le $__fastfetch_min_cols; or test "$LINES" -le $__fastfetch_min_lines
        if test "$__fastfetch_is_narrow" -ne 1
            # -x: plain `clear` also wipes scrollback since ncurses 6.1
            clear -x
            set -g __fastfetch_is_narrow 1
        end
    else
        set -g __fastfetch_is_narrow 0
    end
end

function __auto_clear_fastfetch_on_resize_cols --on-variable COLUMNS
    __fastfetch_check_resize
end

function __auto_clear_fastfetch_on_resize_lines --on-variable LINES
    __fastfetch_check_resize
end
