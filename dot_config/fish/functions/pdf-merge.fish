function pdf-merge
    if test (count $argv) -lt 3
        echo "Usage: pdf-merge <output.pdf> <input1.pdf> <input2.pdf> ..."
        return 1
    end

    pdfcpu merge $argv
end
