# 🥮 Mooncake dotfiles

My personal dotfiles and system configurations, managed using [chezmoi](https://www.chezmoi.io/).

These dotfiles are heavily based on **CachyOS** (not just Arch), specifically the various packages that Cachy ships as default (fish, varuous KDE bloat etc.). Ideally you should have installed CachyOS selecting for hyprland in Calamares.

## 🚀 Installation

1. Tweak CachyOS via the CachyOS Hello app and apply your preferred baseline system tweaks, remind to enable cachy-update;
2. chezmoi.toml: Prepare your chezmoi.toml configuration file with your specific variables, use another device with it to find the format.
3. Finay install chezmoi and apply the dotfiles:

```fish
pacman -S chezmoi
chezmoi init --apply nMaax
```

## 📝 TODOs

- [ ] Double check SSDM and keyring PAM signal with kwallet
- [ ] Use git filter-repo to scrub away binaries and easyeffects .config files (remind about irs files)
