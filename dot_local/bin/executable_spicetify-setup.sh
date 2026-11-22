#!/bin/bash
set -euo pipefail

COMFY_REPO="${1:-https://github.com/Comfy-Themes/Spicetify.git}"
MARKETPLACE_INSTALL_URL="${2:-https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh}"
SPICETIFY_INSTALL_URL="${3:-https://raw.githubusercontent.com/spicetify/cli/main/install.sh}"

echo "Setting up Spicetify..."
echo "By default we will wipe anything related to spicetify first, to make a clean installation"

rm -rf "$HOME/.config/spicetify"

if ! pacman -Q spotify &>/dev/null; then
  paru -S --needed spotify
fi

echo "Installing Spicetify CLI..."
export PATH="$HOME/.spicetify:$PATH"
if ! command -v spicetify &>/dev/null; then
  curl -fsSL "$SPICETIFY_INSTALL_URL" | sh
fi
if [ -x "$HOME/.spicetify/spicetify" ]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$HOME/.spicetify/spicetify" "$HOME/.local/bin/spicetify"
fi

echo "Setting up Spicetify permissions..."
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

mkdir -p "$HOME/.config/spotify"
touch "$HOME/.config/spotify/prefs"

spicetify config prefs_path "$HOME/.config/spotify/prefs"

spicetify backup apply --no-restart

SPICETIFY_CONFIG_DIR="$HOME/.config/spicetify"
SPICETIFY_THEMES_DIR="$SPICETIFY_CONFIG_DIR/Themes"

echo "Installing Comfy theme for Spicetify..."
mkdir -p "$SPICETIFY_THEMES_DIR"
cd "$SPICETIFY_THEMES_DIR"
git clone "$COMFY_REPO" ComfyRepo
mv ./ComfyRepo/Comfy/ ./
rm -rf ./ComfyRepo/

spicetify config current_theme Comfy color_scheme Comfy
spicetify config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1
spicetify config spotify_launch_flags -- "--enable-features=UseOzonePlatform|--ozone-platform=wayland"
spicetify apply --no-restart

echo "Installing Spicetify Marketplace... (⚠️ not really the Arch way, but it doesnt touch anything outside home/)"

MARKETPLACE_SCRIPT="$(mktemp)"
trap 'rm -f "$MARKETPLACE_SCRIPT"' EXIT
curl -fsSL "$MARKETPLACE_INSTALL_URL" -o "$MARKETPLACE_SCRIPT"
sed -i 's/spicetify apply/spicetify apply --no-restart/g' "$MARKETPLACE_SCRIPT"
sh "$MARKETPLACE_SCRIPT"

echo "Spotify, Spicetify, Comfy, and Marketplace cleanly installed!"
