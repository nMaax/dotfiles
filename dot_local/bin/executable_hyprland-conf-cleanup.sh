#!/bin/bash
set -euo pipefail

# Manual, opt-in cleanup of the legacy hyprlang (.conf) Hyprland config, kept
# around on purpose as a fallback while hyprland.lua is being trialed.
# NOT run automatically by any chezmoi script -- run this yourself, by hand,
# only once you've fully committed to the Lua config and no longer want the
# .conf files as a rollback path.
#
# NOTE: unlike the noctalia-v4-cleanup.sh removal, this one has basically no
# functional impact -- Hyprland already loads hyprland.lua INSTEAD of
# hyprland.conf whenever the former exists, so the .conf files are already
# dead weight, not something actively in use. This is pure tidying.
#
# What this does:
#   Removes ~/.config/hypr/hyprland.conf and every file under
#   ~/.config/hypr/hyprland/ (autostart.conf, env.conf, input.conf,
#   keybindings.conf, lookandfeel.conf, misc.conf, monitors.conf,
#   performance.conf, permissions.conf, plugins.conf, rules.conf).
#
# Deliberately NOT touched:
#   - ~/.config/hypr/xdph.conf -- a different program's config
#     (xdg-desktop-portal-hyprland), unrelated to the Lua migration.
#   - ~/.config/hypr/noctalia/ -- managed by the noctalia package, never
#     ours to touch.
#
# IMPORTANT: this only removes the LIVE files. Those same files are still
# tracked in the chezmoi source tree (dot_config/hypr/hyprland.conf,
# dot_config/hypr/hyprland/*.conf), so the next `chezmoi apply` will just
# recreate them from source. To make the removal permanent, the chezmoi
# source tree needs updating too (git rm + adjust .chezmoiignore if needed)
# -- ask Claude to help with that part once you're here; it's a source-repo
# edit, not something this script attempts.

echo "This will remove the legacy hyprland.conf and hyprland/*.conf files"
echo "(hyprland.lua is already the active config -- this is pure cleanup)."
read -rp "Continue? [y/N] " answer
if [[ "${answer,,}" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

rm -f ~/.config/hypr/hyprland.conf
rm -rf ~/.config/hypr/hyprland

echo "Done. Remember: the chezmoi source tree still has these files tracked --"
echo "ask Claude to help remove them there too, or a future 'chezmoi apply' will"
echo "bring them back."
