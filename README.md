# 🥮 Mooncake dotfiles

Personal dotfiles and system configurations, just the way I like it.

These dotfiles are heavily based on **CachyOS** (not just Arch), specifically the various packages that Cachy ships (fish, varuous KDE bloat etc.). Ideally you should have installed CachyOS selecting for hyprland during the Calamares installation.

Managed using [chezmoi](https://www.chezmoi.io/).

## ⚠️ Manual Prerequisites

Due to a dependency loop during fresh installation (Chezmoi evaluates templates — including the SSH config that calls `keepassxc-cli` — *before* running any install scripts), the following steps **must be performed manually** before running `chezmoi init --apply`:

1. **Install MEGA CMD and KeePassXC:**

   ```fish
   sudo pacman -S keepassxc
   paru -S megacmd-bin
   ```

2. **Log into MEGA:**

   ```fish
   mega-login
   ```

3. **Set up the MEGA sync for the root folder containing the KeePass database:**

   ```fish
   mkdir -p ~/MEGA
   mega-sync ~/MEGA/ /
   ```

4. **Wait for the sync to complete**, then verify that both the KeePass database (`.kdbx` file) and the keyfile are present locally.

5. **Create `~/.config/chezmoi/chezmoi.toml`** with the correct KeePassXC database path and keyfile path. Use an existing device to copy the correct format and values.

## 🚀 Installation

1. Tweak CachyOS via the CachyOS Hello app and apply your preferred baseline system tweaks, remind to enable cachy-update;
2. Prepare your chezmoi.toml configuration file with your specific variables, use another device with it to find the format;
3. Finally install chezmoi and apply the dotfiles:

```fish
pacman -S chezmoi
chezmoi init --apply nMaax
```

## ✏️ Post-Installation Notes

### 🦉 Noctalia

- **Documentation:** View further information at [docs.noctalia.dev](https://docs.noctalia.dev/).
- **Stability Warning:** `ddcutil` is installed by default but may cause instability with certain monitors. You can remove it via:
    `sudo pacman -Rns ddcutil`
- **Theming:** The following is automated by the install script (out-of-the-box):
  - All Noctalia templates pre-enabled: GTK, Qt, KColorScheme, Ghostty, Hyprland, btop, Spicetify, Telegram, Zen Browser, cava, Discord, VSCode.
  - GTK dark mode (`adw-gtk3` + `prefer-dark`) applied via `gsettings`.
  - Qt theming via `qt6ct` with `QT_QPA_PLATFORMTHEME` set in Hyprland env.
  - Zen Browser `userChrome.css` configured automatically if Zen has been launched at least once before `chezmoi apply` runs (otherwise, re-run `chezmoi apply` after first Zen launch).
  - **Remaining manual steps** (require in-app interaction):
    - **Discord:** Open Equibop → Settings → Themes → enable one of the two Noctalia themes.
    - **VSCode:** Install the `NoctaliaTheme` extension from the marketplace, then select it via `Ctrl+Shift+P` → *Preferences: Color Theme*.
    - **Steam (optional):** Install [Millennium](https://docs.steambrew.app/users/getting-started/installation) + [Material-Theme](https://steambrew.app/theme?id=ipYjqODds05KMcvh7QJn), select *Matugen* in the theme color dropdown. See the [Steam theming guide](https://docs.noctalia.dev/theming/program-specific/steam/).
    - **Flatpak GTK apps:** Install sandbox theme variants:
      ```sh
      flatpak install org.gtk.Gtk3theme.adw-gtk3-dark
      flatpak install org.gtk.Gtk3theme.adw-gtk3
      ```
  - **Zen Browser appearance:** Try the [Zen-Zero theme](https://sameerasw.com/zen).

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
- [ ] Use git filter-repo to scrub away binaries and easyeffects .config files (remind about irs files)
  - [ ] Maybe send Wallpapers, Gifs and Binaries to another repo and symlink here? I could use a git submodule
  - [ ] Also SilentSDDM Themese could be put in a different repo, and then linked via submodules or something
- [ ] Prepare some default wallpapers x colorschemes combinations
- [x] Review theming via Noctalia is well managed in install scripts (try also to pass documentation to a GitHub Agent)
