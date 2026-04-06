function latex2txt
    set -l base_name (string replace -r '\.tex$' '' $argv[1])
    echo "Creating Text file..."
    pandoc -s $argv[1] -o $base_name.txt
    echo "Done: $base_name.txt"
end
