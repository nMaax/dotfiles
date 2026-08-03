function pdf-merge -d "Merge multiple PDFs into one via pdfcpu"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-merge <output.pdf> <input1.pdf> <input2.pdf> ..."
        return 0
    end

    if test (count $argv) -lt 3
        echo "Usage: pdf-merge <output.pdf> <input1.pdf> <input2.pdf> ..." >&2
        return 1
    end

    pdfcpu merge $argv
end
