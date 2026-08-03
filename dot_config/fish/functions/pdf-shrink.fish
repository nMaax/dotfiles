function pdf-shrink -d "Shrink a PDF's file size via ghostscript"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-shrink <input.pdf> <output.pdf>"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: pdf-shrink <input.pdf> <output.pdf>" >&2
        return 1
    end

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
        -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$argv[2] $argv[1]
end
