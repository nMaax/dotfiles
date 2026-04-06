function latex2md
    set -l base_name (string replace -r '\.tex$' '' $argv[1])
    echo "Creating Markdown..."
    pandoc -s $argv[1] -o $base_name.md
    echo "Done: $base_name.md"
end
