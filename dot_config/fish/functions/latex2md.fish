function latex2md -d "Convert a LaTeX file to Markdown via pandoc"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: latex2md <file.tex>"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: latex2md <file.tex>" >&2
        return 1
    end

    set -l base_name (string replace -r '\.tex$' '' $argv[1])
    echo "Creating Markdown..."
    pandoc -s $argv[1] -o $base_name.md
    echo "Done: $base_name.md"
end
