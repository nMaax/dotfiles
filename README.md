# 🌌 Dotfiles

My personal dotfiles and system configurations, managed using [chezmoi](https://www.chezmoi.io/).
These dotfiles are heavily based on the assumtpion to run on **CachyOS** (not just Arch), and various packages that Cachy ships are installed. More specifically, these will run only on a fresh-install of CachyOS, eventually with or without the installation of the hyprland's package via Calamers install process.

## Pre-Installation Steps

1. Tweak CachyOS: Open the CachyOS Hello app and apply your preferred baseline system tweaks (including enabling cachy-update).
2. KeePass & Secrets: Ensure your KeePass database is synced/available and place your KeePass keyfile in the correct location.
3. chezmoi.toml: Prepare your chezmoi.toml configuration file with your specific variables (e.g., nordvpn_token, tailscale_authkey, name, email).

## 🚀 Installation

To install chezmoi, initialize the repository, and apply the dotfiles all in a single command, open your terminal and run:

```bash
pacman -S chezmoi
chezmoi init --apply nMaax
```

## 📝 TODOs

- [ ] Double check SSDM and keyring PAM signal with kwallet
- [ ] Generalize hyprland.conf in different files (and update the chezmoi script accordingly)
- [ ] Remove decorations in GTK and Qt apps(?) > See <https://gemini.google.com/share/c8a1eda7ec71>
- [ ] Use git filter-repo to scrub away binaries and easyeffects .config files (remind about irs files)
