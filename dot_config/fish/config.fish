# *** CACHYOS CONFIGS ***s
source /usr/share/cachyos-fish-config/cachyos-config.fish

# *** FUNCTIONS ***
function fish_greeting
    # Only run fastfetch if the terminal width is greater than 80 characters
    if test "$COLUMNS" -gt 80
        fastfetch
    end
end

function pdf-shrink
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
        -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$argv[2] $argv[1]
end

function pdf-ocr
    ocrmypdf --deskew --clean $argv[1] $argv[1]
end

alias pdf-merge="pdfcpu merge"
alias pdf-split="pdfcpu split"
alias pdf-pages="pdfcpu collect" # Extract specific pages: pdf-pages in.pdf out.pdf 1-3

# Convert Markdown to PDF
alias md2pdf="pandoc -o output.pdf"

# Extract images from PDF into a folder
function pdf-images
    mkdir -p ./extracted-images
    pdfimages -j $argv[1] ./extracted-images/img
end

# Rip all text out of a PDF
alias pdf-to-txt="pdftotext"

# Remove a password from a PDF
function pdf-unlock
    qpdf --password=$argv[2] --decrypt $argv[1] unlocked_$argv[1]
end

function hyperion
    # Change background color to PoliTo Deep Blue when connected to Hyperion
    printf "\e]11;#1a0b2e\a"
    ssh hyperion
    # Revert the color back to a default black (doesnt affect other terminal sessions)
    printf "\e]11;#000000\a"
end

# *** INTERACTIVE-ONLY CONFIGS  ***
if status is-interactive
    # Start the ssh agent and add your key
    keychain --eval --quiet .ssh/id_ed25519 | source
    # Start starship for a eye-candy terminal interaction
    starship init fish | source
end
