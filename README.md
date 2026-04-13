# 🥮 Mooncake dotfiles

Personal dotfiles and system configurations, just the way I like it.

These dotfiles are heavily based on **CachyOS** (not just Arch), specifically the various packages that Cachy ships (fish, varuous KDE bloat etc.). Ideally you should have installed CachyOS selecting for hyprland during the Calamares installation.

> Managed using [chezmoi](https://www.chezmoi.io/).

## 🧁 Installation

> [!WARNING]
> **This is NOT a run-and-forget installation.** The install script will prompt you at several points. Keep an eye on the terminal throughout the entire process.

1. Tweak CachyOS via the CachyOS Hello app and apply your preferred baseline system tweaks, remind to enable cachy-update;
2. Prepare your `~/.config/chezmoi/chezmoi.toml` configuration file with your specific variables

```toml
[data]
  name = "nMaax"
  email = "you@example.com"
  tailscale_authkey = "tskey-auth-XXXXXXXXXXXXX"
  nordvpn_token = "nvpnkey-auth-XXXXXXXXXXXXX"
  gaming = true
```

1. Install chezmoi and apply the dotfiles

```fish
pacman -S chezmoi
chezmoi init --apply nMaax
```

> [!WARNING]
> `ddcutil` has been installed during the install scripts, it may cause instability with certain monitors. You can remove it via `sudo pacman -Rns ddcutil` if you encounter issues.

> [!WARNING]
> Run `./test.sh` to verify SDDM works before rebooting to avoid being locked out anytime you edit SDDM themes!

> [!NOTE]
> Prefer **systemd-owned Hyprland** instead of plain one at the SDDM login screen to ensure autostart scripts function correctly.

### Handling missing polkit agent password prompt in CachyOS Hello

If CachyHello won't accept your password on a Hyprland-only installation (i.e., no Plasma), the polkit-kde-agent is likely missing from your background processes. You must ensure this agent is running so CachyHello can trigger the authentication pop-up required to apply your changes. To fix do the following:

1. Open your hyprland.conf: vim ~/.config/hypr/hyprland.conf.
2. Add this line to your "exec-once" section (or anywhere at the bottom):

```conf
exec-once = /usr/lib/polkit-kde-authentication-agent-1
```

1. Save and restart Hyprland (Super + M or just log out).

> [!NOTE]
> If you aren't using KDE, the path might be `/usr/lib/lxpolkit` or similar. Cachy usually defaults to the KDE agent even on Hyprland anyway, so this should be quite rare.

## 🥞 Post-Installation Notes

### ☁️ MEGA & KeePassXC

Both `megacmd-bin` and `keepassxc` are installed by the script as regular packages. Set them up manually after installation:

1. **Log into MEGA** and configure your sync:

   ```fish
   mega-login
   mkdir -p ~/MEGA
   mega-sync ~/MEGA/ /
   ```

2. **Open KeePassXC** and point it at your database once the MEGA sync completes. Remind to place the key-file as well.

### 🔑 Keyring, SDDM, and stability

KWallet presents some issues in non-Plasma environments, the isntall scripts tried to address a clean patching of these issues out of the box, however some issues may still be present, especially with Electron apps who rely on safe storage.

Further information can be found at [Arch Wiki: KDE Wallet](https://wiki.archlinux.org/title/KDE_Wallet) and [Electron Safe Storage Info](https://www.electronjs.org/docs/latest/api/safe-storage).

**When you are prompted to create a wallet** (i.e. the first time an application requests one), use **exactly** these settings:

- **Name:** `kdewallet` (the default; any other name will not be unlocked automatically by PAM)
- **Encryption:** `Blowfish` (required for `kwallet-pam` auto-unlock; GnuPG encryption is incompatible)
- **Password:** your current **user login password** (PAM unlocks the wallet by matching it against the login password)

### 🔐 SSH

The install script enables and starts both `sshd` and the user-level `ssh-agent` automatically. But you still need to create a key pair and distribute your public key wherever you want to authenticate. Here are some common procedures you may want to do:

#### Generating a key

```fish
ssh-keygen -t ed25519 -C "axew"
```

Accept the default path (`~/.ssh/id_ed25519`) and choose a strong passphrase. The new key is picked up automatically by the running `ssh-agent`.

#### Connecting to GitHub

1. Copy your public key to the clipboard:

   ```fish
   cat ~/.ssh/id_ed25519.pub | wl-copy
   ```

2. Go to **GitHub → Settings → SSH and GPG keys → New SSH key**, paste it and save.
3. Test the connection:

   ```fish
   ssh -T git@github.com
   ```

   You should see: `Hi <username>! You've successfully authenticated…`

> [!NOTE]
> You could be prompted to either create a new wallet, or to unlock the current one, refer to the Keyring section for details.

1. Tell Git to use SSH for GitHub remotes (optional, but recommended):

   ```fish
   git config --global url."git@github.com:".insteadOf "https://github.com/"
   ```

#### Connecting to another machine

Copy your public key to the remote host (replace `user@host` with your target):

```fish
ssh-copy-id user@host
```

Or manually append `~/.ssh/id_ed25519.pub` to `~/.ssh/authorized_keys` on the remote.

Optionally, create or edit `~/.ssh/config` to define shortcuts:

```
Host myserver
    HostName 192.168.1.10
    User myuser
    IdentityFile ~/.ssh/id_ed25519
```

Then connect simply with `ssh myserver`.

### 🎨 Theming

Noctalia presents a standard approach to sync apps colorschemes with its own theme, each app requires its own procedure, part of it can be automated via code, and some other not. Further information at [docs.noctalia.dev/theming](https://docs.noctalia.dev/theming/basic-app-theming/).

You can retrive the list of apps on which automtic theming is set on the Noctalia settings themeselves. Note however that part of those may still require some in-app manual intervention, here below are some steps you shall take to complete the theming:

#### GTK and Qt

- **qt5ct** (`qt5ct` command): Set **Color scriptheme** to `noctalia`, **General font** to `SF Pro`, **Fixed-width font** to `CaskaydiaCove Nerd Font Mono`
- **qt6ct** (`qt6ct` command): Same as above.
  - Qt theming via `qt6ct` with `QT_QPA_PLATFORMTHEME` has been already set in Hyprland config files for environment variables (`env.conf`).
- **GTK** (`nwg-look`): Ensure Preferences > .config/gtk-4.0 is disabled.
  - `adw-gtk3` + `prefer-dark` was already applied via `gsettings` during the install script.
- GTK apps will automatically fetch the color scheme from the above, while Qt apps must be configured separately going inside app-settings and finding the colorscheme item.

#### Specific apps

- **Zen Browser:** Open `about:config` → set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`; then open Settings → General → set Website Appearance to Auto; finally Restart Zen Browser.
- **Discord:** Open Equibop → Settings → Themes → enable one of the two Noctalia themes.
- **VSCode:** Install the `NoctaliaTheme` extension from the marketplace, then select it via `Ctrl+Shift+P` → *Preferences: Color Theme*.
- **Telegram:** Open Settings → Chat Settings → scroll to the bottom and enable the custom color theme.
- **Steam**: Install [Material-Theme](https://steambrew.app/theme?id=ipYjqODds05KMcvh7QJn) and add it in the Millenium Theme Settings, select *Matugen* in the theme color dropdown.
- All others apps should not require any intervention (e.g. neovim, btop etc.), hopefuly.

> [!NOTE]
> If some apps do not properly fetch the color scheme even after having followed the noctalia guidelines, try to diasable and re-enable them, as well as chaning color-scheme as a whole.\

Furthermore, you can install other themes for apps yourself, have a look at:

- [ZenZero](https://sameerasw.com/zen)
- [BetterDiscord](https://betterdiscord.app/themes)
- [Millenium for Steam](https://steambrew.app/themes)

### 🌐 Broswer(s) setup

The stuff that I usually use during my browsing experience, what do you want with this:

- **Extensions**:
  - [uBlock Origin](https://ublockorigin.com/) – content & ad blocker
  - [ClearURLs](https://github.com/ClearURLs/Addon) – strips tracking parameters from URLs
  - [Tridactyl](https://github.com/tridactyl/tridactyl) – Vim-style keyboard navigation (Firefox/Zen)
  - [MarkDownload](https://github.com/deathau/markdownload) – download pages as Markdown
  - [DarkReader](https://darkreader.org/help/en/) - automatic dark theming
  - [Zen Internet](https://addons.mozilla.org/en-US/firefox/addon/zen-internet/) - zen-synched theming for common webpages, needed for [ZenZero](https://sameerasw.com/zen)
- **Zen Mods**:
  - [Transparent Zen](https://zen-browser.app/mods/642854b5-88b4-4c40-b256-e035532109df) – make zen look transparent, needed for [ZenZero](https://sameerasw.com/zen)

Eventually consider also [Volume Control](https://github.com/Chaython/volumecontrol), [Web Archives](https://github.com/dessant/web-archives), [YouTube Improved](https://github.com/code-charity/youtube), etc.

Furthermore, here is a list of some good misc websites for assets:

- [Pinterest](https://it.pinterest.com/): for propics
- [Wallheaven](https://wallhaven.cc/): for static backgrounds
- [MotionBGs](https://motionbgs.com/): for animated wallpapers
- Guide on how to convert WallpaperEngine backgrounds into video files: from [WallapaperEngine itself](https://help.wallpaperengine.io/en/functionality/export.html), from [Steam community](https://steamcommunity.com/sharedfiles/filedetails/?id=2277828676)

### 🔥 Spicetify Extension

Other stuff I use on Spicetify, my advice is to use the marketplace as much as possible

- Spicy Lyrics (instead of Beautiful Lyrics, which seem to be deprecated)
- Gloabal Stats for songs, to fetch info on different song.
- Lucid Theme (instead of the Confy default one)

> [!WARNING]
> Disable Comfy theme via spicetify cli if you want to install a different one!
> Run the following:
>
> ```bash
> spicetify config current_theme " "
> spicetify apply
> ```

### 🎮 Gaming

Of course Mooncake is designed with gaming in mind too, they will then apply some minor common installations and tweaks if cachyos gaming packages are detected. For more details, visit the [CachyOS Gaming Wiki](https://wiki.cachyos.org/configuration/gaming). Here are some handy notes at your disposal to complete your gaming experience:

#### 🚀 Steam Launch Options

- **NVIDIA:** `PROTON_ENABLE_WAYLAND=1 PROTON_DLSS_UPGRADE=1 PROTON_NVIDIA_LIBS_NO_32BIT=1 PROTON_USE_NTSYNC=1 PROTON_ENABLE_HDR=1 ENABLE_HDR_WSI=1 game-performance %command%`
- **AMD:** `PROTON_USE_NTSYNC=1 ENABLE_LAYER_MESA_ANTI_LAG=1 PROTON_FSR4_UPGRADE=1 game-performance %command%`

#### ⚙️ Steam/Proton Settings

- **Compatibility:** Set `proton-cachyos (slr)` as your default Proton layer.
- **Pre-caching:** If using Proton-CachyOS, navigate to **Steam -> Settings -> Downloads** and **UNCHECK**:
  - "Enable Shader Pre-caching"
  - "Allow background processing of Vulkan shaders"

#### 🍷 Lutris, Heroic and other Launchers Settings

- **System Options:** Enable **"Disable Lutris Runtime"** and **"Prefer system libraries"**.
- **Compatibility:** Ensure the layer is set to `proton-cachyos (slr)`. Just as in Steam.
- **Launch Options:** Mirror the launch options used in Steam, each launcher has its own way to do that, which usually do not differ much from Steam anywya, refer to documentation. (e.g. Heroic will provide some form entries for variables and values)

---

## 📝 TODOs

- [x] Notify user at start that they will need to interact with the install script, this is not a run and forget
- [x] How to install quickshell-overview-git without making it conflict with noctalia-qs?
- [x] What about ssh? What should one do to connect to github or another machine?
- [x] Add Work/ directory, and add it to XDG_DIRS file too
- [x] Check if you can move some of the external links as `.externalchezmoi.toml`'s items
- [x] Re-organize the README
- [x] Double check SDDM PAM patching for LUKS is ok
- [x] Review install scripts
- [x] Review dotfiles themselves
- [ ] Seems like some irs and jpg file is still in history, clean it and remove all branches
- [ ] Close all PRs, and delete all branches
- [ ] Refine WALLHACK Wallpapers (add theme to dotfiles-assets)
- [ ] Prepare some default wallpapers x colorschemes combinations
- [ ] Once everything is finished, add screenshoots and videos in this README

### For the future

- [ ] Move to fish install script
- [ ] Generalize for pure arch: track what Cachy installs, including fundamentals like bluetooth, networkmanager, fish, cachyos fish setup, gpu drivers etc.
- [ ] Fix ksshaskpass Qt::font empty error
- [ ] Fix OBS Browser install to automate substitution that requires the vlc plugin variant from lua to be changed in luajit
