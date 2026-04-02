#!/bin/bash

# For the future: move to shelly when it becomes default in CachyOS

set -euo pipefail

if ! grep -qi 'CachyOS' /etc/os-release; then
  echo "This script is intended to run on CachyOS. Exiting."
  exit 1
fi

echo "==> Checking for cachy-update..."
if sudo pacman -Q cachy-update &>/dev/null; then
  echo "Running cachy-update..."
  cachy-update
else
  echo "Warning: 'cachy-update' is not installed."
  echo "Please open 'CachyOS Hello' to enable cach-update, and remind to tweak your system!"
fi

echo "==> Checking for base packages..."
BASE_PACKAGES=(binutils base-devel git vim appmenu-gtk-module libdbusmenu-glib hyperland xdg-desktop-portal-hyprland chezmoi)
for pkg in "${BASE_PACKAGES[@]}"; do
  if ! pacman -Qi "$pkg" &>/dev/null; then
    echo "Installing missing package: $pkg"
    sudo pacman -S --needed --noconfirm "$pkg"
  fi
done

echo "==> Installing other utilities..."
sudo pacman -S --needed --noconfirm smartmontools ffmpeg glow dust bat ripgrep fd btop trash-cli ghostscript pandoc poppler qpdf
paru -S --needed --noconfirm caligula-bin pdfcpu-bin ocrmypdf tesseract-data-eng tesseract-data-ita
# tesseract-data-nld tesseract-data-fra tesseract-data-deu tesseract-data-spa tesseract-data-por \
# tesseract-data-jpn tesseract-data-jpn_vert tesseract-data-kor tesseract-data-kor_vert \
# tesseract-data-chi_sim tesseract-data-chi_sim_vert tesseract-data-chi_tra tesseract-data-chi_tra_vert

echo "==> Setting Wireless Regdom to Italy"
sudo sed -i 's/^WIRELESS_REGDOM=/#&/' /etc/conf.d/wireless-regdom && sudo sed -i '/WIRELESS_REGDOM="IT"/s/^#//' /etc/conf.d/wireless-regdom

echo "==> Update TLDR;"
tldr --update

echo "==> Enable smartmontools to check for SSD health"
sudo systemctl enable --now smartd

echo "==> Setup Uncomplicated Firewall"
sudo ufw enable

echo "==> Installing MEGAcmd and KeePassXC"
paru -S --needed --noconfirm megacmd-bin
sudo pacman -S --needed --noconfirm keepassxc

echo "==> Starting MEGAcmd server..."
mega-cmd-server &>/dev/null &
sleep 3 # Give the server a few seconds to initialize

echo "==> Enabling MEGA"
read -rp "   Enter MEGA Email: " email
mega-login "$email"

echo "==> Synching local MEGA/ with cloud..."
mkdirp -p ~/MEGA
mega-sync ~/MEGA/ /
echo "Checking for the MEGA session to be ready..."

while ! mega-sync | grep -q "Synced"; do
  echo "Still syncing... please wait."
  sleep 5
done
echo "MEGA folder is now fully Synced!"

if ! ls ~/MEGA/KeePassXC/Password.kdbx &>/dev/null; then
  echo "Couldn't find the KeePassXC database, maybe MEGA didn't download it."
  exit 1
fi

echo -e "Please ensure your KeePass database is available and place your keyfile in the correct location.\nPress [Enter] to continue once you are ready..."
read -r

echo "==> Initializing chezmoi..."
chezmoi init --apply

echo "==> Done!"
