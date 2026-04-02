#!/bin/bash

# For the future: move to shelly when it becomes default in CachyOS

set -euo pipefail

if ! grep -qi 'CachyOS' /etc/os-release; then
  echo "This script is intended to run on CachyOS."
  echo "Did nothing, will close now."
  exit 1
fi

read -rp "Did you tweak CachyOS already? [Y/n] " answer
if [[ "${answer,,}" != "y" && -n "$answer" ]]; then
  echo "Go back and tune whatever you lik. Closing, come back later."
  exit 1
fi

read -rp "Did you place the chezmoi.toml and the KeePass keyfile? [Y/n] " answer
if [[ "${answer,,}" != "y" && -n "$answer" ]]; then
  echo "Please place the chezmoi.toml and KeePass keyfile in their proper locations before proceeding. Closing, come back later."
  exit 1
fi

echo "==> Checking for cachy-update..."
if sudo pacman -Q cachy-update &>/dev/null; then
  echo "Running cachy-update..."
  cachy-update
else
  echo "Warning: 'cachy-update' is not installed."
  echo "Did you really listen to me before??"
  echo "Please open 'CachyOS Hello' to enable cachy-update, and remind to tweak your system!"
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
sudo pacman -S --needed --noconfirm smartmontools ffmpeg imagemagick glow dust bat ripgrep fd btop trash-cli ghostscript pandoc poppler qpdf
paru -S --needed --noconfirm caligula-bin pdfcpu-bin ocrmypdf tesseract-data-eng tesseract-data-ita

echo "==> Setting Wireless Regdom to Italy"
sudo sed -i 's/^WIRELESS_REGDOM=/#&/' /etc/conf.d/wireless-regdom && sudo sed -i '/WIRELESS_REGDOM="IT"/s/^#//' /etc/conf.d/wireless-regdom

echo "==> Update TLDR;"
tldr --update

echo "==> Enable smartmontools to check for SSD health"
sudo systemctl enable --now smartd

echo "==> Setup Uncomplicated Firewall"
sudo ufw enable

echo "==> Enable SSH daemon"
sudo systemctl enable --now sshd

echo "==> Installing MEGAcmd and KeePassXC"
paru -S --needed --noconfirm megacmd-bin
sudo pacman -S --needed --noconfirm keepassxc

echo "==> Enabling MEGA"
if ! mega-whoami >/dev/null 2>&1; then
  echo "You are not logged in to MEGA."
  read -rp "   Enter MEGA Email: " email
  mega-login "$email"
else
  echo "Already logged in to MEGA."
fi

echo "==> Checking MEGA is synced with cloud..."
if ! mega-sync | grep "Synced"; then
  echo "Mega is not synced. Syncing now."
  mkdir -p ~/MEGA
  mega-sync ~/MEGA/ /
  while ! mega-sync | grep -q "Synced"; do
    echo "Still syncing... please wait."
    sleep 3
  done
else
  echo "Mega is already synced."
fi

echo "Mega synced with specifications:"
mega-sync

echo "Issues with MEGA:"
mega-sync-issues

if ! ls ~/MEGA/KeePassXC/Password.kdbx &>/dev/null; then
  echo "Couldn't find the KeePassXC database, maybe MEGA didn't download it."
  echo "Can't proceed, will close now. This script is idempotent so you can run it again and resume where left."
  exit 1
fi

echo -e "Please ensure your KeePass database is available and place your keyfile in the correct location.\nPress [Enter] to continue once you are ready..."
read -r

echo "==> Initializing chezmoi..."
chezmoi init --apply

echo "==> Done!"
