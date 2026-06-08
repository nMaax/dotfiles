#!/bin/bash
set -euo pipefail

COMFY_REPO="${1:-https://github.com/Comfy-Themes/Spicetify.git}"
MARKETPLACE_INSTALL_URL="${2:-https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh}"

echo "Installing Spotify (spicetify) from AUR..."
echo "By default we will wipe anything related to spicetify first, to make a clean installation"

rm -rf "$HOME/.config/spicetify"

paru -S --noconfirm spotify spicetify-cli

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
spicetify apply --no-restart

echo "Installing Spicetify Marketplace... (⚠️ not really the Arch way, but it doesnt touch anything outside home/)"

curl -fsSL "$MARKETPLACE_INSTALL_URL" -o /tmp/install_marketplace.sh
sed -i 's/spicetify apply/spicetify apply --no-restart/g' /tmp/install_marketplace.sh
sh /tmp/install_marketplace.sh
rm /tmp/install_marketplace.sh

echo "Spotify, Spicetify, Comfy, and Marketplace cleanly installed!"
