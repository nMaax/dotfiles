function pdf-pages -d "Collect a page selection from a PDF into a new PDF via pdfcpu"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-pages <input.pdf> <output.pdf> <page_selection>"
        echo "Example: pdf-pages input.pdf output.pdf 1-3,5"
        return 0
    end

    if test (count $argv) -lt 3
        echo "Usage: pdf-pages <input.pdf> <output.pdf> <page_selection>" >&2
        echo "Example: pdf-pages input.pdf output.pdf 1-3,5" >&2
        return 1
    end

    pdfcpu collect -pages $argv[3] $argv[1] $argv[2]
end
