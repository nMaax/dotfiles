function latex2txt -d "Convert a LaTeX file to plain text via pandoc"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: latex2txt <file.tex>"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: latex2txt <file.tex>" >&2
        return 1
    end

    set -l base_name (string replace -r '\.tex$' '' $argv[1])
    echo "Creating Text file..."
    pandoc -s $argv[1] -o $base_name.txt
    echo "Done: $base_name.txt"
end
