function mount_remote
    # 1. Validation: Ensure we have two args and an '@' in the first arg
    if test (count $argv) -lt 2; or not string match -q "*@*" "$argv[1]"
        echo "Error: Missing arguments or invalid format."
        echo "Usage: mount_remote user@host remote_folder"
        return 1
    end

    set -l connection_string $argv[1]
    set -l remote_folder $argv[2]

    # 2. Extract the username (everything before the @)
    set -l remote_user (string split -m 1 "@" $connection_string)[1]

    # 3. Construct the paths
    # We assume the remote path is always under the user's home
    set -l remote_full_path "/home/$remote_user/$remote_folder"

    # Local mount matches the host and folder name
    set -l local_mount "$HOME/mounts/$connection_string/$remote_folder"

    # 4. Create local directory and mount
    mkdir -p $local_mount

    echo "Attempting to mount $remote_full_path..."
    sshfs $connection_string:$remote_full_path $local_mount -o reconnect,ConnectTimeout=5

    if test $status -eq 0
        echo "✅ Mounted at: $local_mount"
    else
        echo "❌ Mount failed. Ensure $connection_string exists and path is correct."
    end
end
