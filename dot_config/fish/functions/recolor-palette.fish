function recolor-palette --description "Shift a hex color palette onto a new base color, preserving each color's original relationship to the base, and emit (or run) the sed commands to apply it to a file"
    argparse a/apply 'f/file=' h/help -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -lt 2
        echo "Usage: recolor-palette [-f|--file target_file] [-a|--apply] <new_base_hex> <original_hex_1> [<original_hex_2> ...]"
        echo
        echo "  <original_hex_1> is the ORIGINAL base color. Every other original hex is"
        echo "  shifted by the same delta it had relative to that base, then re-applied"
        echo "  on top of <new_base_hex>."
        echo
        echo "  -f, --file    target file to edit (default: theme.css)"
        echo "  -a, --apply   run sed immediately instead of just printing the command"
        echo
        echo "Example:"
        echo "  recolor-palette -f theme.css bb3a1e 5a3f4d fff5fa fff0f5 ffe8f2"
        if set -q _flag_help
            return 0
        end
        return 1
    end

    set -l target_file theme.css
    if set -q _flag_file
        set target_file $_flag_file
    end

    set -l new_base (string replace -r '^#' '' -- $argv[1])
    set -l original_palette (string replace -r '^#' '' -- $argv[2..-1])

    # --- deltas: how each color originally differed from the base ---
    set -l base_hex $original_palette[1]
    set -l prev_r (math 0x(string sub -l 2 -s 1 $base_hex))
    set -l prev_g (math 0x(string sub -l 2 -s 3 $base_hex))
    set -l prev_b (math 0x(string sub -l 2 -s 5 $base_hex))

    set -l delta_r
    set -l delta_g
    set -l delta_b
    for hex in $original_palette[2..-1]
        set -l r (math 0x(string sub -l 2 -s 1 $hex))
        set -l g (math 0x(string sub -l 2 -s 3 $hex))
        set -l b (math 0x(string sub -l 2 -s 5 $hex))
        set -a delta_r (math $r - $prev_r)
        set -a delta_g (math $g - $prev_g)
        set -a delta_b (math $b - $prev_b)
        set prev_r $r
        set prev_g $g
        set prev_b $b
    end

    # --- apply those deltas on top of the new base color ---
    set -l curr_r (math 0x(string sub -l 2 -s 1 $new_base))
    set -l curr_g (math 0x(string sub -l 2 -s 3 $new_base))
    set -l curr_b (math 0x(string sub -l 2 -s 5 $new_base))
    set -l new_palette $new_base

    for i in (seq (count $delta_r))
        set curr_r (math "max(0, min(255, $curr_r + $delta_r[$i]))")
        set curr_g (math "max(0, min(255, $curr_g + $delta_g[$i]))")
        set curr_b (math "max(0, min(255, $curr_b + $delta_b[$i]))")
        set -a new_palette (printf '%02x%02x%02x' $curr_r $curr_g $curr_b)
    end

    # --- build one chained, case-insensitive sed command ---
    set -l sed_args
    for i in (seq (count $original_palette))
        set -a sed_args -e "s/#$original_palette[$i]/#$new_palette[$i]/gi"
    end

    if set -q _flag_apply
        echo "Applying to $target_file ..."
        sed -i.bak $sed_args $target_file
        echo "Done. Backup saved as $target_file.bak"
    else
        echo "# Run this to update $target_file (backup saved as $target_file.bak)"
        echo sed -i.bak $sed_args $target_file
    end
end
