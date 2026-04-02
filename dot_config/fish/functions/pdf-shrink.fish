function pdf-shrink
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
        -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$argv[2] $argv[1]
end
