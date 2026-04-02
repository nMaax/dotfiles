function pdf-images
    mkdir -p ./extracted-images
    pdfimages -j $argv[1] ./extracted-images/img
end
