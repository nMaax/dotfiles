function pdf-ocr
    ocrmypdf --deskew --clean $argv[1] $argv[1]
end
