# 🥮 dotfiles

Personal dotfiles and system configurations, just the way I like it.

These dotfiles are heavily based on **CachyOS** (not just Arch), specifically the various packages that Cachy ships with it's own base installation (fish, sddm, various KDE bloat etc.).

Ideally you should have installed CachyOS selecting for hyprland during the Calamares installation, or without any DE/WM (in such case 🥮 will install Hyprland automatically).

> Managed using [chezmoi](https://www.chezmoi.io/).

## Installation

> [!WARNING]
> **This is NOT a run-and-forget installation.** The install script will prompt you at several points. Keep an eye on the terminal throughout the entire process.

1. Prepare your `~/.config/chezmoi/chezmoi.toml` configuration file

```toml
[data]
  name = "nMaax"
  email = "you@example.com"
  tailscale_authkey = "tskey-auth-XXXXXXXXXXXXX" # Leave "" if you want to skip tailscale
  nordvpn_token = "nvpnkey-auth-XXXXXXXXXXXXX" # Leave "" if you want to skip nordvpn
  gaming = true
```

During install, you will have the option to automatically wipe `tailscale_authkey` / `nordvpn_token` from `~/.config/chezmoi/chezmoi.toml` right after their use.

2. Install chezmoi and apply the dotfiles

```fish
pacman -S chezmoi
chezmoi init --apply nMaax
```

> [!WARNING]
> `ddcutil` will been installed, which may cause instability with certain monitors. You can remove it via `sudo pacman -Rns ddcutil` if you encounter any issue.

> [!NOTE]
> During log-in in SDDM choose **systemd-owned Hyprland** instead of the plain one, to ensure autostart scripts function correctly (e.g. cachy-update tray icon).

### Handling missing polkit agent password prompt in CachyOS Hello

If you would like to tweak CachyOS before running 🥮, but CachyOS Hello won't accept your password on a Hyprland-only installation (i.e., no Plasma), the polkit-kde-agent is likely missing from your background processes. You must ensure this agent is running so CachyOS Hello can trigger the authentication pop-up required to apply your changes. This will likely happen if you proceed to use CachyHello before 🥮 installation, as the below is already implemented in 🥮.

To fix, do the following:

1. Open your hyprland.conf: `vim ~/.config/hypr/hyprland.conf`.
2. Add this line to your "exec-once" section (or anywhere at the bottom):

```conf
exec-once = /usr/lib/polkit-kde-authentication-agent-1
```

3. Save and restart Hyprland (Super + M or just log out and log back in).
4. Now you should be able to tweak cachy as you like, and proceed with 🥮 installation.

## Post-Installation

### MEGA & KeePassXC

Both `megacmd-bin` and `keepassxc` are installed by the script as regular packages.

Set them up manually after installation:

1. **Log into MEGA** and configure your sync:

   ```fish
   mega-login
   mkdir -p ~/MEGA
   mega-sync ~/MEGA/ /
   ```

2. **Open KeePassXC** and point it at your database once the MEGA sync completes. Remember to place the key-file as well!

### Keyring (KWallet) and SSH

KWallet is the password manager of choice in 🥮, due to the already wide presence of KDE-ecosystem tools by CachyOS itself. However, KWallet often presents some issues in non-Plasma environments, the install scripts will try to cleanly patch these issues out of the box, togheter pre-setted config files; however some may still be present, especially with Electron apps that rely on the Electron safe-storage feature.

Crucially, remind that **when you are prompted to create a wallet** (i.e. the first time an application requests one), use **exactly** these settings:

- **Name:** `kdewallet` (the default; any other name will not be unlocked automatically by PAM)
- **Encryption:** `Blowfish` (required for `kwallet-pam` auto-unlock; GnuPG encryption is incompatible)
- **Password:** your current **user login password** (PAM unlocks the wallet by matching it against the login password)

Or simply do it by yourself after installing 🥮.

Further information can be found at [Arch Wiki: KDE Wallet](https://wiki.archlinux.org/title/KDE_Wallet) and [Electron Safe Storage Info](https://www.electronjs.org/docs/latest/api/safe-storage).

The install script enables both `sshd` and the user-level `ssh-agent` automatically. But you still need to create a key pair and distribute your public key wherever you want to authenticate. Here are some common procedures you may want to do:

#### Generating a key

```fish
ssh-keygen -t ed25519 -C "axew"
```

Accept the default path (`~/.ssh/id_ed25519`) and optionally choose a passphrase. The new key is picked up automatically by the running `ssh-agent`.

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
> You could be prompted to either create a new wallet, or to unlock the current one, refer to the above section for details.

4. Tell Git to use SSH for GitHub remotes (optional, but recommended):

   ```fish
   git config --global url."git@github.com:".insteadOf "https://github.com/"
   ```

#### Connecting to another machine

Copy your public key to the remote host (replace `user@host` with your remote target machine):

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

### Theming

Noctalia presents a standard approach to sync apps colorschemes with its own theme, each app requires its own procedure, part of it can be automated via code, and some other not. Further information at [docs.noctalia.dev/theming](https://docs.noctalia.dev/theming/basic-app-theming/).

You can retrieve the list of apps on which automatic theming is set on the Noctalia settings themselves. Note however that part of those may still require some in-app manual intervention, here below are some steps you shall take to complete the theming:

#### GTK and Qt

- **qt5ct** (`qt5ct` command): Set **Color scriptheme** to `noctalia`, **General font** to `SF Pro`, **Fixed-width font** to `CaskaydiaCove Nerd Font Mono`
- **qt6ct** (`qt6ct` command): Same as above.
  - Qt theming via `qt6ct` with `QT_QPA_PLATFORMTHEME` has been already set in Hyprland config files for environment variables (`env.conf`).
- **GTK** (`nwg-look`): Set general font to `SF Pro Regular`, then ensure Preferences > .config/gtk-4.0 is disabled, eventually clear if you found it enabled.
  - `adw-gtk3` + `prefer-dark` was already applied via `gsettings` during the install script.
- GTK apps will automatically fetch the color scheme from the above, while Qt apps must be configured separately going inside app-settings and finding the colorscheme item.

#### Specific apps

- **Zen Browser:** Open `about:config` → set `toolkit.legacyUserProfileCustomizations.stylesheets` to `true`; then open Settings → General → set Website Appearance to Auto; finally Restart Zen Browser.
- **Discord:** Open Equibop → Settings → Themes → enable one of the two Noctalia themes.
- **VSCode:** Install the `NoctaliaTheme` extension from the marketplace, then select it via `Ctrl+Shift+P` → *Preferences: Color Theme*.
- **Telegram:** Open Settings → Chat Settings → scroll to the bottom and enable the custom color theme.
- **Steam**: Install [Material-Theme](https://steambrew.app/theme?id=ipYjqODds05KMcvh7QJn) and add it in Millenium Settings > Theme, then click the three dots > configure > style > colors > select *Matugen* in the theme color dropdown.
- All others apps should not require any intervention (e.g. neovim, btop etc.), hopefully.

> [!NOTE]
> If some apps do not properly fetch the color scheme even after having followed the noctalia guidelines, try to disable and re-enable them, as well as changing color-scheme as a whole.\

Furthermore, you can install other themes for apps yourself, have a look at:

- [ZenZero](https://sameerasw.com/zen)
- [BetterDiscord](https://betterdiscord.app/themes)
- [Millenium for Steam](https://steambrew.app/themes)

🥮 also supports [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine)! If you installed Steam you can see how to set it up and the [related plugin](https://noctalia.dev/plugins/linux-wallpaperengine-controller/)

### Browser setup

The stuff that I usually use during my browsing experience, these are completely optional and at your preference, do what you want with them:

- **Extensions**:
  - [uBlock Origin](https://ublockorigin.com/) – content & ad blocker
  - [ClearURLs](https://github.com/ClearURLs/Addon) – strips tracking parameters from URLs
  - [Tridactyl](https://github.com/tridactyl/tridactyl) – Vim-style keyboard navigation (Firefox/Zen)
  - [MarkDownload](https://github.com/deathau/markdownload) – download pages as Markdown
  - [DarkReader](https://darkreader.org/help/en/) - automatic dark theming
- **Zen Mods**:
  - [Transparent Zen](https://zen-browser.app/mods/642854b5-88b4-4c40-b256-e035532109df) – make zen look transparent, needed for [ZenZero](https://sameerasw.com/zen)

Eventually consider also 
  - [Volume Control](https://github.com/Chaython/volumecontrol)
  - [Web Archives](https://github.com/dessant/web-archives)
  - [YouTube Improved](https://github.com/code-charity/youtube)

Furthermore, here is a list of some good misc websites for assets in case you wanted to customize 🥮:

- [Pinterest](https://it.pinterest.com/): for propics
- [Wallhaven](https://wallhaven.cc/): for static backgrounds
- [MotionBGs](https://motionbgs.com/): for animated wallpapers
- Guide on how to convert WallpaperEngine backgrounds into video files: from [WallapaperEngine itself](https://help.wallpaperengine.io/en/functionality/export.html), from [Steam community](https://steamcommunity.com/sharedfiles/filedetails/?id=2277828676)

### Spicetify extensions

Other stuff I use on Spicetify, I warmly advice is to use the marketplace as much as possible to install them! Spicetify and Spicetify marketplace are automatically installed with 🥮.

If you want to re-run just the Spicetify setup without `chezmoi apply`, run:

```bash
~/.local/bin/spicetify-setup.sh
```

- [Spicy Lyrics](https://github.com/Spikerko/spicy-lyrics) (instead of Beautiful Lyrics, which seem to be deprecated!)
- Global Stats for songs, to fetch info on different songs.
- Shuffle+ for a fisher-yates randomization with zero bias.
- [Lucid Theme](https://github.com/sanoojes/spicetify-lucid) (instead of the Confy default one, tho this one looks quite heavy, bloated and dirty, ngl.)

> [!WARNING]
> Disable Comfy theme via spicetify cli if you want to install a different one!
> Run the following:
>
> ```bash
> spicetify config current_theme " "
> spicetify apply
> ```

### Gaming

Of course 🥮 is designed with gaming in mind too, 🥮 will apply some common installations and tweaks if cachyos gaming packages are detected. For more details, visit the [CachyOS Gaming Wiki](https://wiki.cachyos.org/configuration/gaming). Here is quick guidance to complete your gaming experience:

#### Launch Options

The below is the common Steam format for launch options, however you can achive an equivalent setup also in other launchers like Heroic and Lutris.

- **NVIDIA:** `PROTON_ENABLE_WAYLAND=1 PROTON_DLSS_UPGRADE=1 PROTON_NVIDIA_LIBS_NO_32BIT=1 game-performance %command%`
- **AMD:** `PROTON_ENABLE_WAYLAND=1 PROTON_FSR4_UPGRADE=1 ENABLE_LAYER_MESA_ANTI_LAG=1 game-performance %command%`

For Lutris specifically, remind to enable **Disable Lutris Runtime** and **Prefer system libraries**

#### Steam/Proton Settings

- **Compatibility:** Set `proton-cachyos (slr)` as your default Proton layer.
- **Pre-caching:** If using Proton-CachyOS, navigate to **Steam -> Settings -> Downloads** and **UNCHECK**:
  - "Enable Shader Pre-caching"
  - "Allow background processing of Vulkan shaders"
 
> [!WARNING]
> 🥮 enables tearing automatically for steam_apps (recognized via hyprland client class), to disable it see [Hyprland wiki](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/) 

### Streaming (P2P)

If you are not satisfyied with the Wayland screenshare when streaming gaming on your Electron app (e.g. Discord) then 🥮 brings some plugins to stream your games with low latency and low added input latency on the game. Namely using `obs-vkcapture`, `lib32-obs-vkcapture`, `obs-pipewire-audio-capture`.

```bash
# Install the Vulkan/OpenGL video capture plugin
paru -S obs-vkcapture lib32-obs-vkcapture

# Install the PipeWire application audio capture plugin
paru -S obs-pipewire-audio-capture
```

1. Launch your game, so its audio and video hooks are active in your system.
2. Open OBS Studio. Under the **Sources** dock, click the **`+`** icon.
3. Add a **Game Capture (Vulkan/OpenGL)** source. Leave its properties on default; it will automatically hook into your game's engine.
4. Click **`+`** again and add an **Application Audio Capture (PipeWire)** source.
5. Inside its properties, find the **Application** dropdown menu and select **`wine64-preloader`** (this represents your Steam Proton / Wine game process).

Because you are explicitly capturing the game audio now, you must turn off OBS's global desktop capture so your friend don't hear everything twice:

* Go to **Settings** $\rightarrow$ **Audio**.
* Under **Global Audio Devices**, change **Desktop Audio** to **Disabled**. Click **Apply**.

To drop your hardware encoding delay down to less than 15 milliseconds, you need to adjust your video framing and reconfigure the NVIDIA NVENC encoder pipeline.

On the left menu, select the **Video** tab. Do not use the "Rescale Output" checkbox in the encoder menu; handle it here instead:

* **Base (Canvas) Resolution:** Match this to your monitor's native resolution (e.g., `2560x1440`).
* **Output (Scaled) Resolution:** Set this to **`1920x1080`** (1080p is the sweet spot).
* **Downscale Filter:** `Bicubic (Sharpened scaling, 16 samples)`.
* **Common FPS Values:** `60`.

Go to the **Output** tab and flip the **Output Mode** at the very top from *Simple* to **Advanced**. In the **Streaming** tab, mirror these exact specifications:

| Setting Field | Value to Select / Type | Why it matters |
| --- | --- | --- |
| **Audio Encoder** | `FFmpeg Opus` | Enforced by WebRTC for instant, crisp sound. |
| **Video Encoder** | `NVIDIA NVENC H.264` | Uses your GPU hardware so your game doesn't lag. |
| **Rate Control** | `CBR` | Delivers a smooth, predictable data stream. |
| **Bitrate** | `6000 Kbps` | Pristine quality for 1080p60 without network bloating. |
| **Keyframe Interval** | `1 s` | Allows the web player to recover instantly from dropped packets. |
| **Preset** | `P1: Fastest (Lowest Latency)` | Bypasses complex frame analysis to prioritize speed. |
| **Tuning** | `Low Latency` | Cuts out internal encoder buffer queues. |
| **Multipass Mode** | `Single Pass` | Processes the frame once instead of twice. |
| **Profile** | `baseline` | Strips out heavy compression loops that cause player buffering. |
| **Look-ahead** | 🔲 **Uncheck** | Prevents the GPU from processing future frames in advance. |
| **Adaptive Quantization** | 🔲 **Uncheck** | Eliminates extra algorithmic calculation passes. |
| **B-Frames** | `0` | **Most Important:** Sends frames out instantly as they render. |

Finally, go to the **Advanced** tab on the left sidebar. Under **General**, change **Process Priority** from *Normal* to **`Above Normal`** or **`High`**. This stops the Linux kernel from starving OBS of resources when your game hits an intense scene.

Now we are ready to run the Meshcast Stream

1. Open your web browser and navigate to **[Meshcast.io](https://meshcast.io/)**.
2. Scroll to the **Stream using WHIP** section, type a unique ID, select your closest regional server location, and click the link generation button.
3. Meshcast will hand you a **WHIP URL** that looks similar to this: `https://cae2.meshcast.io/whip/MadaMada1234`.
4. In OBS, go to **Settings** > **Stream**.
5. Set **Service** to **WHIP**.
6. Split your Meshcast link across the two input boxes like this:
- **Server:** `https://cae2.meshcast.io/whip/`
- **Bearer Token:** `MadaMada1234` *(The unique string at the very end of your link)* (or just skip the token and put the whole link in the server field)
7. Click **Apply** and **OK**.

Now you can copy the **Watch Page Link** provided by the Meshcast interface (e.g., `https://meshcast.io/view.html?geo=cae2&id=MadaMada1234`) and send it over to your friends.

Hit **Start Streaming** in OBS. Your game stream will bypass your local home firewall completely via Meshcast's edge servers, and your friends will see your high-framerate gameplay and isolated audio with a sub-second delay.

---

## 📝 TODOs

- [ ] Solve TODOs around the codebase and move to Lua
- [ ] Try to rice [quickshell overview](https://github.com/Shanu-Kumawat/quickshell-overview#%EF%B8%8F-configuration)
- [ ] Make [paletter.py](https://pastebin.com/r0BzzEqK) a runnable script with, e.g., a fish function to automatically generate color palettes
- [ ] Once everything is finished, add screenshots and videos in this README

### For the future

- [ ] Prepare WALLHACK Wallpapers -> Make a release for dotfiles-assets if files are too large
- [ ] Enhance assets by introducing a github CI action that autogenerates README with gallery, like [dharmx](https://github.com/dharmx/walls)
- [ ] Try out these [QyLock](https://github.com/Darkkal44/qylock) as new SDDM presets
- [ ] Try out [Hyprland Scroll Overview](https://github.com/yayuuu/hyprland-scroll-overview) plugin instead of qs overiview once it works in Hyprland 0.55
- [ ] Try out [Noctalia Polkit Agent](https://noctalia.dev/plugins/polkit-agent) (you must uninstall kde polking agent, maybe this is not the right choice in cachy)
- [ ] Generalize for pure Arch by reproducing what Cachy installs, including fundamentals like bluetooth, networkmanager, fish, cachyos fish setup, gpu drivers etc.
