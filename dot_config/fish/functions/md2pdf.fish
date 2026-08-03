function md2pdf -d "Convert a Markdown file to PDF via pandoc/typst"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: md2pdf <input.md> <output.pdf>"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: md2pdf <input.md> <output.pdf>" >&2
        return 1
    end

    pandoc $argv[1] \
        -o $argv[2] \
        --pdf-engine=typst \
        -V margin-top=1in \
        -V margin-bottom=1in \
        -V margin-left=1in \
        -V margin-right=1in \
        --highlight-style=tango
end
