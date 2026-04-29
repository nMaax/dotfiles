function unmount_remote
    set -l target $argv[1]
    if test -z "$target"
        echo "Usage: unmount_remote [path_to_mount]"
        return 1
    end

    # Detect OS and use appropriate command
    if uname | grep -q Darwin
        umount $target
    else
        fusermount -u $target
    end

    if test $status -eq 0
        echo "Successfully unmounted and closed connection."
        # Optional: Clean up the empty directory
        rmdir $target
    else
        echo "Failed to unmount. Is the directory busy (e.g., an open terminal or file explorer)?"
    end
end
