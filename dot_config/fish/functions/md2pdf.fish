function md2pdf
    pandoc $argv[1] \
        -o $argv[2] \
        --pdf-engine=typst \
        -V margin-top=1in \
        -V margin-bottom=1in \
        -V margin-left=1in \
        -V margin-right=1in \
        --highlight-style=tango
end
