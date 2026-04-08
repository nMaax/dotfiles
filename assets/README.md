# 🖼️ dotfiles-assets

> **This directory is a git submodule.**
> It should point to [`nMaax/dotfiles-assets`](https://github.com/nMaax/dotfiles-assets).

This submodule stores binary assets referenced by the dotfiles:

| File in this repo | Installed to |
|---|---|
| `.face` | `~/.face` (SDDM avatar / user picture) |
| `.logo` | `~/.logo` (Fastfetch / shell branding logo) |
| `wallpapers/` | `~/Pictures/Wallpapers/` |

## Setting up the assets repo

1. Create a new GitHub repository named **`dotfiles-assets`** under your account.
2. Push the binary asset files there:

```bash
# From your local dotfiles-assets clone
git add .face .logo wallpapers/
git commit -m "chore: add initial assets"
git push origin main
```

3. Register it as a submodule in this dotfiles repo:

```bash
# From the root of this dotfiles repo
git submodule add https://github.com/nMaax/dotfiles-assets.git assets
git commit -m "chore: add dotfiles-assets submodule"
```

4. After cloning the dotfiles repo on a fresh machine, run:

```bash
git submodule update --init --recursive
```

The chezmoi `run_once_before` script handles this automatically during `chezmoi apply`.
