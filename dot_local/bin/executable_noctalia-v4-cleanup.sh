#!/bin/bash
set -euo pipefail

# Manual, opt-in cleanup for Noctalia v4 (noctalia-shell), kept installed
# on purpose as a fallback while v5 (noctalia) is being trialed side by side.
# NOT run automatically by any chezmoi script -- run this yourself, by hand,
# only once you've fully committed to v5 and no longer need v4 as a fallback.
#
# What this does:
#   1. Removes the noctalia-shell package (confirmed safe: its noctalia-qs
#      dependency stays installed either way, since quickshell-overview-git
#      -- the unrelated scrolloverview plugin UI -- also depends on it).
#   2. Removes the live v4 config leftovers under ~/.config/noctalia/
#      (settings.json, plugins.json, colorschemes/).
#
# IMPORTANT: step 2 only removes the LIVE files. Those same files are still
# tracked in the chezmoi source tree (dot_config/noctalia/settings.json,
# plugins.json, colorschemes/**), so the next `chezmoi apply` will just
# recreate them from source. To make the removal permanent, the chezmoi
# source tree needs updating too (git rm + adjust .chezmoiignore) -- ask
# Claude to help with that part once you're here; it's a source-repo edit,
# not something this script attempts.

echo "This will remove the noctalia-shell package and your v4 Noctalia config"
echo "(~/.config/noctalia/settings.json, plugins.json, colorschemes/)."
read -rp "Continue? [y/N] " answer
if [[ "${answer,,}" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

sudo pacman -Rns --noconfirm noctalia-shell

rm -f ~/.config/noctalia/settings.json ~/.config/noctalia/plugins.json
rm -rf ~/.config/noctalia/colorschemes

echo "Done. Remember: the chezmoi source tree still has these files tracked --"
echo "ask Claude to help remove them there too, or a future 'chezmoi apply' will"
echo "bring them back."
