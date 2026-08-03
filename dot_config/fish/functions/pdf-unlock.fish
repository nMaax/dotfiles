function pdf-unlock -d "Decrypt a password-protected PDF via qpdf"
    if contains -- -h $argv; or contains -- --help $argv
        echo "Usage: pdf-unlock <input.pdf> <password>"
        return 0
    end

    if test (count $argv) -lt 2
        echo "Usage: pdf-unlock <input.pdf> <password>" >&2
        return 1
    end

    qpdf --password=$argv[2] --decrypt $argv[1] unlocked_$argv[1]
end
