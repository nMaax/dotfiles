#!/bin/bash

set -euo pipefail

# --- Color Definitions ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Logging Functions ---
info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1"; }

echo ""
info "📦 [Stage 1] Installing prerequisites..."
echo ""

info "🤓 Installing Nerd Fonts..."
sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd ttf-iosevka-nerd ttf-cascadia-code-nerd
info "🍎 Installing Apple Fonts..."
paru -S --needed --noconfirm apple-fonts

# Install Apple Emoji
EMOJI_URL="https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260219-2aa12422/ttf-apple-emoji.pkg.tar.zst"
EMOJI_FILE="/tmp/ttf-apple-emoji.pkg.tar.zst"
EXPECTED_SHA="6ca3fcda54437675e8ea55cdc1ad06d4c33b485b04eadd0e74763f040bf9c021" # Last Update: 19 Feb 2026

if ! pacman -Qs ttf-apple-emoji >/dev/null; then
  info "📥 Downloading verified Apple Emoji package..."
  curl -L "$EMOJI_URL" -o "$EMOJI_FILE"

  # Verify hash before installing
  if echo "$EXPECTED_SHA  $EMOJI_FILE" | sha256sum -c -; then
    sudo pacman -U --noconfirm "$EMOJI_FILE"
    success "Apple Emoji installed successfully."
  else
    error "SHA256 checksum mismatch for Apple Emoji! Aborting font installation."
  fi
  rm -f "$EMOJI_FILE"
else
  success "Apple Emoji is already installed."
fi

info "🌙 Installing Noctalia dependencies..."
paru -S --needed --noconfirm cliphist wlsunset xdg-desktop-portal evolution-data-server hyprshot

echo "🖥️ Installing KDE suite and utility apps..."
sudo pacman -S --needed --noconfirm \
  qt6ct qt5ct adw-gtk-theme \
  archlinux-xdg-menu ark dolphin-plugins filelight \
  okular haruna kwrite gwenview

echo "🐬 Fixing Dolphin 'Open With' amnesia..."
sudo ln -sf /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu
rm -rf ~/.cache/ksycoca6*
kbuildsycoca6 --noincremental

info "🦉 Installing Noctalia..."
paru -S --needed --noconfirm noctalia-shell

echo ""
success "✅ [Stage 1] Prerequisites installed."
echo ""
