function audio-cycle --description 'Cycle the default audio input or output device'
    # Requires: pactl (pulseaudio-utils / pipewire-pulse), notify-send (libnotify)
    argparse i/input o/output h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: audio-cycle (-i | --input) | (-o | --output)"
        echo
        echo "  -i, --input   Cycle the default audio INPUT device (source)"
        echo "  -o, --output  Cycle the default audio OUTPUT device (sink)"
        return 0
    end

    if set -q _flag_input; and set -q _flag_output
        echo "audio-cycle: pass only one of -i/--input or -o/--output" >&2
        return 1
    end
    if not set -q _flag_input; and not set -q _flag_output
        echo "audio-cycle: pass one of -i/--input or -o/--output" >&2
        return 1
    end

    set -l kind
    set -l label
    if set -q _flag_input
        set kind source
        set label Input
    else
        set kind sink
        set label Output
    end

    # List of available device names (skip monitor "sources" that mirror sinks)
    set -l devices
    if test "$kind" = source
        set devices (pactl list short sources | awk '{print $2}' | string match -v '*.monitor')
    else
        set devices (pactl list short sinks | awk '{print $2}')
    end

    if test (count $devices) -eq 0
        notify-send -i dialog-warning "Audio $label" "No $kind devices found"
        return 1
    end

    # Current default device
    set -l current
    if test "$kind" = source
        set current (pactl get-default-source)
    else
        set current (pactl get-default-sink)
    end

    # Locate current device's position in the list
    set -l idx 1
    for i in (seq (count $devices))
        if test "$devices[$i]" = "$current"
            set idx $i
            break
        end
    end

    # Advance to the next device, wrapping around
    set -l device_count (count $devices)
    set -l next_idx (math "$idx % $device_count + 1")
    set -l next_device $devices[$next_idx]

    # Apply as the new default
    if test "$kind" = source
        pactl set-default-source "$next_device"
    else
        pactl set-default-sink "$next_device"
    end

    # Move already-running streams over to the new device too
    if test "$kind" = source
        for id in (pactl list short source-outputs | awk '{print $1}')
            pactl move-source-output $id "$next_device" 2>/dev/null
        end
    else
        for id in (pactl list short sink-inputs | awk '{print $1}')
            pactl move-sink-input $id "$next_device" 2>/dev/null
        end
    end

    # Grab a human-readable description for the notification
    set -l desc (pactl list $kind"s" | awk -v name="$next_device" '
        /^(Sink|Source) #/ { insink = 0 }
        $0 ~ "Name: " name "$" { insink = 1 }
        insink && /Description:/ {
            sub(/.*Description: /, "")
            print
            exit
        }
    ')
    if test -z "$desc"
        set desc $next_device
    end

    set -l icon audio-speakers
    set -l replace_id 91827
    if test "$kind" = source
        set icon audio-input-microphone
        set replace_id 91828
    end

    notify-send -r $replace_id -i $icon "Audio $label switched" "$desc"
end
