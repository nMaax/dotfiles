function scrub-file -d "Wipe metadata and reset timestamps on files"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: scrub-file <file1> [file2 ...]"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: scrub-file <file1> [file2 ...]" >&2
        return 1
    end

    for file in $argv
        if test -f $file
            echo "Scrubbing $file..."

            # 1. Use ExifTool to wipe all internal metadata tags
            # -all= removes all metadata
            # -overwrite_original prevents creating a "_original" backup file
            exiftool -all= -overwrite_original $file

            # 2. Reset filesystem timestamps (MAC: Modification, Access, Creation)
            # Sets it to Jan 1st, 2000, at 00:00:00
            touch -t 200001010000.00 $file

            echo "Done. $file is now clean and timestamped to Jan 1, 2000."
        else
            echo "Error: $file not found."
        end
    end
end
