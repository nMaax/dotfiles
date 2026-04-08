# 🖥️ sddm-silent-custom

> **This directory is a git submodule.**
> It should point to a fork or personal customisation of the [`silent` SDDM theme](https://github.com/mamutal91/sddm-silent-theme).

Place your customised `sddm-silent-theme` files here so they are applied on top of the
AUR-installed package during `chezmoi apply`.

## Expected structure

```
sddm-silent-custom/
├── theme.conf        # Override default theme settings
├── Backgrounds/      # Custom background images
└── ...               # Any other overrides
```

## Setting up the custom SDDM theme repo

1. Create a new GitHub repository (e.g. **`sddm-silent-custom`**) under your account.
2. Place your customisations there.
3. Register it as a submodule in this dotfiles repo:

```bash
git submodule add https://github.com/nMaax/sddm-silent-custom.git sddm-silent-custom
git commit -m "chore: add sddm-silent-custom submodule"
```

4. The chezmoi run script (`run_once_after_tweaks.sh.tmpl`) will overlay these files on top of
   `/usr/share/sddm/themes/silent/` automatically.

## Without customisations

If you have no custom files here the script will simply skip the overlay step and use the
default AUR-installed theme, which is fine for a stock Silent SDDM setup.
