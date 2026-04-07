# 🥮 Mooncake dotfiles

Personal dotfiles and system configurations, just the way I like it.

These dotfiles target **CachyOS** (Hyprland profile) as the primary platform, but the install scripts are designed to also work on a **pure Arch Linux** installation out of the box. When run on Arch, the scripts will bootstrap any missing CachyOS defaults (paru, fish, sddm, PipeWire, Dolphin, Qt Wayland layers, etc.) before proceeding with the rest of the setup.

Managed using [chezmoi](https://www.chezmoi.io/).

## 🚀 Installation

### CachyOS (recommended)

1. Tweak CachyOS via the CachyOS Hello app and apply your preferred baseline system tweaks, remind to enable cachy-update;
2. Prepare your chezmoi.toml configuration file with your specific variables, use another device with it to find the format;
3. Finally install chezmoi and apply the dotfiles:

```fish
pacman -S chezmoi
chezmoi init --apply nMaax
```

### Pure Arch Linux

1. Boot into a fresh Arch install with `base`, `base-devel`, `git`, and `networkmanager` available;
2. Prepare your `chezmoi.toml` (see a CachyOS device for the expected format);
3. Install chezmoi and apply — the prerequisite script will detect the non-CachyOS environment, bootstrap `paru`, and install all required base packages automatically:

```bash
pacman -S chezmoi
chezmoi init --apply nMaax
```

## ✏️ Post-Installation Notes

### 🦉 Noctalia

- **Documentation:** View further information at [docs.noctalia.dev](https://docs.noctalia.dev/).
- **Stability Warning:** `ddcutil` is installed by default but may cause instability with certain monitors. You can remove it via:
    `sudo pacman -Rns ddcutil`
- **Theming:** Enable consistent looks across your apps.
  - [App Theming Guide](https://docs.noctalia.dev/theming/basic-app-theming/)
  - **Zen Browser:** Try the [Zen-Zero theme](https://sameerasw.com/zen).

### 🔑 Keyring & Security

- **KWallet:** Create a new wallet via `kwalletmanager` using your **user password** to enable automatic login. Have a look at offical documentation to set up keyring autologin and linking with Electrong apps.
  - [Arch Wiki: KDE Wallet](https://wiki.archlinux.org/title/KDE_Wallet)
  - [Electron Safe Storage Info](https://www.electronjs.org/docs/latest/api/safe-storage)

### 🖥️ Silent SDDM

- **Session Selection:** Ensure you select **systemd-owned Hyprland** at the SDDM login screen to ensure autostart scripts function correctly.
- **Safety Check:** Run `./test.sh` in `$SILENT_SDDM_DIR` to verify SDDM works before rebooting to avoid being locked out.
- **Custom Themes**: Since themes are not part of the `/home` folder I couldn't add them here, but you can copy them manually from your devices.

### 🎮 Gaming Reminders

#### 🚀 Steam Launch Options

- **NVIDIA:** *TODO*
- **AMD:** `PROTON_USE_NTSYNC=1 ENABLE_LAYER_MESA_ANTI_LAG=1 PROTON_FSR4_UPGRADE=1 game-performance %command%`

#### ⚙️ Steam & Proton Settings

- **Compatibility:** Set `proton-cachyos (slr)` as your default Proton layer.
- **Pre-caching:** If using Proton-CachyOS, navigate to **Steam -> Settings -> Downloads** and **UNCHECK**:
  - "Enable Shader Pre-caching"
  - "Allow background processing of Vulkan shaders"

#### 🍷 Lutris, Heroic and other Launchers Settings

- **System Options:** Enable **"Disable Lutris Runtime"** and **"Prefer system libraries"**.
- **Compatibility:** Ensure the layer is set to `proton-cachyos (slr)`.
- **Launch Options:** Mirror the settings used in Steam (refer to documentation).

> For more details, visit the [CachyOS Gaming Wiki](https://wiki.cachyos.org/configuration/gaming).

## 📝 TODOs

- [ ] Double check SSDM and keyring PAM signal with kwallet
- [ ] Use git filter-repo to scrub away binaries and easyeffects .config files (remind about irs files) --> Maybe send Wallpapers, Gifs and Binaries to another repo and symlink here? I could use a git submodule
- [ ] Prepare some default wallpapers x colorschemes combinations
- [ ] Review keybindings and cleanup cheatsheet to be readable
