function latex2pdf -d "Compile a LaTeX file to PDF via pdflatex"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: latex2pdf <file.tex>"
        return 0
    end

    if test (count $argv) -eq 0
        echo "Usage: latex2pdf <file.tex>" >&2
        return 1
    end

    set -l base_name (string replace -r '\.tex$' '' $argv[1])
    echo "Creating PDF..."
    pdflatex -interaction=batchmode $argv[1] >/dev/null
    # Clean up auxiliary files
    rm -f $base_name.aux $base_name.log $base_name.out
    echo "Done: $base_name.pdf"
end
