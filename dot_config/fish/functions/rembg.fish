function rembg -d "Prints a guide on how to safely use rembg on Arch using uv"
    set_color cyan --bold
    echo "=========================================================="
    echo "  🖼️  HOW TO REMOVE IMAGE BACKGROUNDS ON ARCH (VIA UV)   "
    echo "=========================================================="
    set_color normal
    echo "Because global pip is disabled on Arch and the AUR package"
    echo "often breaks, the best way to run 'rembg' is via an isolated"
    echo "uv environment."
    echo ""

    set_color yellow --bold
    echo "STEP 1: Install uv (if you haven't already)"
    set_color normal
    echo "  sudo pacman -S uv"
    echo ""

    set_color yellow --bold
    echo "STEP 2: Create a workspace and virtual environment"
    set_color normal
    echo "  mkdir -p ~/rembg-workspace && cd ~/rembg-workspace"
    echo "  uv venv"
    echo "  source .venv/bin/activate.fish"
    echo ""

    set_color yellow --bold
    echo "STEP 3: Install rembg and Pillow"
    set_color normal
    echo "  uv pip install rembg Pillow"
    echo ""

    set_color yellow --bold
    echo "STEP 4: Create the Python script"
    set_color normal
    echo "Create a file named "(set_color green)"remove_bg.py"(set_color normal)" and paste this code:"
    set_color magenta
    echo ----------------------------------------------------------
    echo "from rembg import remove"
    echo "from PIL import Image"
    echo ""
    echo "input_path = 'input.png'   # Change this to your image!"
    echo "output_path = 'output.png' # Where to save the result"
    echo ""
    echo "print('Processing image...')"
    echo "input_image = Image.open(input_path)"
    echo "output_image = remove(input_image)"
    echo "output_image.save(output_path)"
    echo "print('Done! Saved to', output_path)"
    echo ----------------------------------------------------------
    set_color normal
    echo ""

    set_color yellow --bold
    echo "STEP 5: Run it!"
    set_color normal
    echo "  python remove_bg.py"
    echo ""

    set_color cyan --bold
    echo "💡 PRO-TIP: The 'No-Code' Shortcut"
    set_color normal
    echo "rembg actually has a built-in CLI! Instead of making a python"
    echo "script every time, you can just use uvx to download and run"
    echo "the CLI in a temporary, disposable environment in one command:"
    set_color green --bold
    echo "  uvx rembg i input.png output.png"
    set_color normal
    echo ""
end
