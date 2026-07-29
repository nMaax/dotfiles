# Cleanup checklist

Things that are safe to remove, but only once you're sure you no longer want the fallback. This
replaces the two `*-cleanup.sh` scripts that used to live in `dot_local/bin/` — a list you read is
better than a script you run blindly, especially when half the steps touch packages or the chezmoi
source tree.

Nothing here is automated. Nothing here is urgent. Everything here is reversible *before* you run it
and mostly not after, so read the "what breaks" line first.

Two recurring gotchas, worth internalising once:

- **Removing a file from the chezmoi source does not delete the copy already in `$HOME`.** You need
  both the `git rm` *and* a manual `rm` of the applied file.
- **Deleting only the live file achieves nothing** — the next `chezmoi apply` recreates it from
  source. Always do the source side too.

---

## 1. Legacy Hyprland `.conf` config

Superseded by `hyprland.lua`. Hyprland loads `hyprland.lua` *instead of* `hyprland.conf` whenever the
former exists, so these files are already inert — this is pure tidying with no functional effect.

- [x] Remove the live files:
      `rm -f ~/.config/hypr/hyprland.conf && rm -rf ~/.config/hypr/hyprland`
- [x] Remove them from the chezmoi source:
      `git rm dot_config/hypr/hyprland.conf && git rm -r dot_config/hypr/hyprland`

**Do not touch:** `~/.config/hypr/xdph.conf` (a different program's config —
`xdg-desktop-portal-hyprland`) or `~/.config/hypr/noctalia/` (managed by the noctalia package).

**What breaks:** nothing, but you lose the ability to roll back to the hyprlang config by deleting
`hyprland.lua`. Keep these until the Lua config has survived a few weeks of daily use.

---

## 2. Noctalia v4 (`noctalia-shell`)

v4 is deliberately still installed alongside v5 as a fallback. v4 and v5 do not conflict as packages
and their configs don't collide (v4 = JSON, v5 = TOML, different paths), so there's no cost to
keeping it beyond disk.

- [ ] Remove the package: `sudo pacman -Rns noctalia-shell`
- [x] Remove the live v4 config:
      `rm -f ~/.config/noctalia/settings.json ~/.config/noctalia/plugins.json && rm -rf ~/.config/noctalia/colorschemes ~/.config/noctalia/templates`
- [x] Remove the v4 config from the chezmoi source: `git rm -r dot_config/noctalia`
- [x] Prune the now-dead `.config/noctalia/**` lines from `.chezmoiignore` (the generated-file
      exclusions and the whole `!.config/noctalia/colorschemes/...` allowlist)
- [x] Also drop the v4 install line from
      `.chezmoiscripts/run_onchange_before_04-hyprland-noctalia.sh.tmpl`
      (`paru -S --needed --noconfirm noctalia-shell`) and the comment block explaining the coexistence

**Keep `noctalia-qs`** — it stays installed either way, because `quickshell-overview-git` (the
unrelated ScrollOverview plugin UI) depends on it.

**What breaks:** your v4 bar layout, pinned apps, enabled plugins and colorschemes are gone for good.
v5 has no migration path from v4, so this is only safe once v5 is fully configured to your liking.

**Careful:** `dot_config/noctalia/user-templates.toml` is *shared* — it's what generates
`~/.config/hypr/lua/colors.lua` for the Hyprland border colours. Do **not** delete that one with the
rest of the v4 config, or the Lua config's colours stop updating on theme change.

---

## 3. Superseded helper scripts

These are dead code — the keybinds that called them now do the work natively in
`dot_config/hypr/lua/keybindings.lua`.

- [x] `hypr-scrolling.sh` — replaced by the `SUPER+X` closure using `hl.get_config` + `hl.config`
- [x] `hypr-toggle.py` — replaced by the `toggle_ws()` closure using `hl.get_windows()`
- [x] Source: `git rm dot_local/bin/executable_hypr-scrolling.sh dot_local/bin/executable_hypr-toggle.py`
- [x] Live: `rm -f ~/.local/bin/hypr-scrolling.sh ~/.local/bin/hypr-toggle.py`
- [x] `hypr-toggle.py`'s optional override file, if you ever made one:
      `rm -rf ~/.config/hypr-toggle` (none existed)

**What breaks:** nothing, as long as `grep -rn 'hypr-toggle\|hypr-scrolling' dot_config/` comes back
empty first. Run that check before deleting.

---

## 4. `hyprshot`

The screenshot keybinds (`PRINT`, `SUPER+PRINT`, `SUPER+SHIFT+PRINT`) now use Noctalia's native
capture, so hyprshot is unused.

- [ ] Drop `hyprshot` from the `paru -S --needed --noconfirm ...` line in
      `.chezmoiscripts/run_onchange_before_04-hyprland-noctalia.sh.tmpl`
- [ ] `sudo pacman -Rns hyprshot`

**What breaks:** you permanently lose per-window capture. Noctalia has no equivalent — its closest
mode is `screenshot-fullscreen pick`, which picks a *monitor*, not a window. If you use window
capture regularly, keep hyprshot and re-bind it to a spare key instead.

---

## 5. Manual settings that chezmoi cannot manage

Noctalia v5 keeps its settings in `~/.local/state/noctalia/settings.toml`, which this repo does not
track. These have to be set through the Settings UI by hand, and will need redoing on a fresh install.

- [ ] Set `[shell.screenshot]` → `directory` to `~/Pictures/Screenshots`. Left empty it defaults to
      `~/Pictures`, so screenshots land somewhere different from where hyprshot used to put them.
- [ ] While you're there, `freeze_screen`, `copy_to_clipboard` and `pipe_command` (e.g. `swappy -f -`
      for annotation) are worth a look — they're the features hyprshot didn't have.
- [ ] Re-add the bar widgets for the v5 plugins if you haven't: `mpvpaper`, `w-engine-widget`,
      `keybinds` (cheatsheet), `cat` (bongo cat). The mpvpaper picker panel is `placement = "attached"`
      and may need its bar widget present as an anchor to open via keybind at all.

---

## 6. Stray files from old bugs

- [x] `rm ~/.local/share/applications/install-webapp.desktop` — created by a bug in
      `run_onchange_after_07-webapps.sh.tmpl` that passed an extra `install-webapp` argument, so the
      app name and URL both became `install-webapp`. The script is fixed; the stray entry isn't
      self-cleaning.
- [x] Check `~/.local/share/icons/webapps/` for a matching orphan icon (found and removed
      `install-webapp.png`).

---

## 7. The scripts this file replaced

`executable_noctalia-v4-cleanup.sh` and `executable_hyprland-conf-cleanup.sh` were removed from the
chezmoi source when this file was written. Per the gotcha at the top, the already-applied copies are
still sitting in `$HOME`:

- [x] `rm -f ~/.local/bin/noctalia-v4-cleanup.sh ~/.local/bin/hyprland-conf-cleanup.sh`
