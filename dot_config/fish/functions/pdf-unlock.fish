function pdf-unlock
    qpdf --password=$argv[2] --decrypt $argv[1] unlocked_$argv[1]
end
