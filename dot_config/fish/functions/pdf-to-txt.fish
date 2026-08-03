function pdf-to-txt -d "Extract text from a PDF via pdftotext"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-to-txt <input.pdf> [output.txt]"
        return 0
    end

    if test (count $argv) -lt 1
        echo "Usage: pdf-to-txt <input.pdf> [output.txt]" >&2
        return 1
    end

    pdftotext $argv
end
