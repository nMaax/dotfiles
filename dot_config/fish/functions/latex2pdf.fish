function latex2pdf
    set -l base_name (string replace -r '\.tex$' '' $argv[1])
    echo "Creating PDF..."
    pdflatex -interaction=batchmode $argv[1] >/dev/null
    # Clean up auxiliary files
    rm -f $base_name.aux $base_name.log $base_name.out
    echo "Done: $base_name.pdf"
end
