function pdf-images -d "Extract embedded images from a PDF into ./extracted-images"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-images <input.pdf>"
        return 0
    end

    if test (count $argv) -lt 1
        echo "Usage: pdf-images <input.pdf>" >&2
        return 1
    end

    mkdir -p ./extracted-images
    pdfimages -j $argv[1] ./extracted-images/img
end
