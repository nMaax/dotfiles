function pdf-ocr -d "OCR a PDF in place (deskew + clean) via ocrmypdf"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-ocr <input.pdf>"
        return 0
    end

    if test (count $argv) -lt 1
        echo "Usage: pdf-ocr <input.pdf>" >&2
        return 1
    end

    ocrmypdf --deskew --clean $argv[1] $argv[1]
end
