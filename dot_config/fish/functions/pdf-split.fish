function pdf-split -d "Split a PDF into separate files via pdfcpu"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-split <input.pdf> [output_dir] [page_span]"
        return 0
    end

    if test (count $argv) -lt 1
        echo "Usage: pdf-split <input.pdf> [output_dir] [page_span]" >&2
        return 1
    end

    pdfcpu split $argv
end
