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

## 🗂️ Asset Submodules

Binary assets (wallpapers, avatar, logo) and custom SDDM theme files are **not** stored in this
repository. They live in dedicated repos referenced as git submodules:

| Submodule path | Repository | Contents |
|---|---|---|
| `assets/` | [`nMaax/dotfiles-assets`](https://github.com/nMaax/dotfiles-assets) | `.face`, `.logo`, `wallpapers/` |
| `sddm-silent-custom/` | [`nMaax/sddm-silent-custom`](https://github.com/nMaax/sddm-silent-custom) | Custom Silent SDDM theme overrides |

The chezmoi `run_once_before_00_submodules.sh.tmpl` script automatically initialises these
submodules and copies the assets to the correct home-directory paths before the rest of the
install runs.

### Fresh clone / after adding the remote repos

```bash
git submodule update --init --recursive
```

### Migrating existing binary files into the assets repo

```bash
# 1. Create & populate the assets repo
git clone https://github.com/nMaax/dotfiles-assets /tmp/dotfiles-assets
cp ~/.face /tmp/dotfiles-assets/.face
cp ~/.logo /tmp/dotfiles-assets/.logo
mkdir -p /tmp/dotfiles-assets/wallpapers
cp ~/Pictures/Wallpapers/* /tmp/dotfiles-assets/wallpapers/
cd /tmp/dotfiles-assets && git add . && git commit -m "chore: initial assets" && git push

# 2. Register the submodule in this repo (if not already done)
cd ~/dotfiles   # or wherever chezmoi source lives
git submodule add https://github.com/nMaax/dotfiles-assets.git assets
git commit -m "chore: add dotfiles-assets submodule"
```

## 🧹 Scrubbing Binary History

Use [`git filter-repo`](https://github.com/newren/git-filter-repo) to permanently remove
binary files (images, video, audio, EasyEffects `.irs` impulse-response files) from the entire
git history. **This rewrites history – coordinate with any collaborators first.**

```bash
# Install git-filter-repo
sudo pacman -S git-filter-repo   # or: paru -S git-filter-repo

# Remove all image / video / audio / binary artefacts from history
git filter-repo --invert-paths \
  --path-glob '*.jpg'  \
  --path-glob '*.jpeg' \
  --path-glob '*.png'  \
  --path-glob '*.gif'  \
  --path-glob '*.webp' \
  --path-glob '*.webm' \
  --path-glob '*.mp4'  \
  --path-glob '*.mkv'  \
  --path-glob '*.avi'  \
  --path-glob '*.mov'  \
  --path-glob '*.mp3'  \
  --path-glob '*.ogg'  \
  --path-glob '*.flac' \
  --path-glob '*.wav'  \
  --path-glob '*.ttf'  \
  --path-glob '*.otf'  \
  --path-glob '*.woff' \
  --path-glob '*.woff2'\
  --path-glob '*.ico'  \
  --path-glob '*.bmp'  \
  --path-glob '*.tiff' \
  --path-glob '*.bin'  \
  --path-glob '*.irs'  \
  --path 'dot_face'    \
  --path 'dot_logo'    \
  --path 'Pictures/'

# Also scrub any EasyEffects config files that were accidentally tracked
git filter-repo --invert-paths \
  --path 'dot_config/easyeffects/'

# Force-push the rewritten history
git push origin --force --all
git push origin --force --tags
```

> **After the scrub:** run `git gc --prune=now --aggressive` to reclaim disk space.

## 📝 TODOs

- [ ] Double check SDDM and keyring PAM signal with kwallet
- [x] Move wallpapers, .face and .logo to `dotfiles-assets` submodule *(see `assets/README.md`)*
- [x] Move Silent SDDM custom theme files to `sddm-silent-custom` submodule *(see `sddm-silent-custom/README.md`)*
- [x] Add `git filter-repo` commands to scrub binary history *(see above)*
- [ ] Prepare some default wallpapers × colorschemes combinations
- [ ] Review theming via Noctalia is well managed in install scripts (try also to pass documentation to a GitHub Agent)
