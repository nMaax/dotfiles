# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal dotfiles for a **CachyOS + Hyprland + Noctalia** desktop, managed with
[chezmoi](https://www.chezmoi.io/). There is no build system, no test suite and no CI — the
"application" is the user's machine, and the closest thing to a test run is `chezmoi apply` followed
by asking the affected program whether it is happy.

Three docs at the root, with distinct jobs:

- `README.md` — user-facing install and post-install setup guide.
- `CLEANUP.md` — read-first checklist of things safe to delete once fallbacks aren't wanted.
  Deliberately **not** a script; it replaced two `*-cleanup.sh` scripts precisely so nothing
  destructive gets run blindly.
- **This file** — how to change things without breaking them.

---

## 1. Commands

### chezmoi

```bash
chezmoi diff                      # what would change in $HOME
chezmoi status                    # short form; see the 99.sh note below
chezmoi apply --exclude=scripts   # DEFAULT for config work: regular files only
chezmoi apply                     # full run, EXECUTES install scripts (sudo prompts) -- user's call
chezmoi add --exclude=externals <target>   # DEFAULT when re-adding config drift
chezmoi cat <target>              # render one file as it would be applied
chezmoi execute-template < .chezmoiscripts/run_onchange_after_07-webapps.sh.tmpl
chezmoi doctor                    # environment sanity
```

`chezmoi execute-template` is the way to test a `.tmpl` change: it renders the template, including
`{{ template "utils.sh.tmpl" . }}` inclusions, **without executing** anything. Use it on scripts
rather than running them.

`chezmoi status` will essentially always show `R .chezmoiscripts/99.sh` pending, and `chezmoi verify`
will exit 1 because of it. That is expected, not a problem: `run_after_99.sh.tmpl` has neither
`once` nor `onchange` in its name, so it is due on *every* apply, and `--exclude=scripts` never runs
it. Ignore that one line; investigate anything else.

### Validating changes

There are no linters installed (no `shellcheck`, `stylua`, `luacheck`) — don't reach for them.
Validation is per-subsystem:

```bash
# Hyprland Lua -- syntax
luac5.4 -p dot_config/hypr/lua/*.lua dot_config/hypr/hyprland.lua

# Hyprland -- did it actually load?
hyprctl reload && hyprctl configerrors     # MUST print nothing

# Shell scripts / templates -- render, don't run
chezmoi execute-template < .chezmoiscripts/<script>.tmpl | bash -n

# Fish functions
fish -n dot_config/fish/functions/<name>.fish
```

### The Hyprland change loop

Do all five steps. Steps 1–2 catch typos; only step 5 catches semantic errors, and Hyprland is
alarmingly tolerant of nonsense (§6).

```bash
luac5.4 -p dot_config/hypr/lua/*.lua dot_config/hypr/hyprland.lua   # 1. syntax
git diff                                                            # 2. review the real diff
chezmoi diff                                                        # 3. what changes in $HOME
chezmoi apply --exclude=scripts                                     # 4. apply
hyprctl reload && hyprctl configerrors                              # 5. must be empty
```

Read the actual `git diff`. Do not report from the list of files you believe you edited.

**Empty `configerrors` is necessary, not sufficient** — it only proves the config *parsed*. To verify
that Lua closures behave, run them through `hyprctl eval`; it only ever prints `ok`, so write results
to a scratch file and read that back:

```bash
hyprctl eval 'local f = io.open("/tmp/probe.txt","w") f:write(tostring(hl.get_config("general.layout"))) f:close()'
```

That technique is how the layout toggle, the window matchers and `hl.dsp.window.move`'s `window`
selector were each confirmed to *work* rather than merely load.

### Probing config logic offline with a stubbed `hl`

The Lua config only ever touches the global `hl`, so any file under `dot_config/hypr/lua/` can be
loaded in plain `lua5.4` against a fake `hl` and driven with synthetic state — no compositor, no
monitors, no plugins. Use it when a closure's branches can't be produced on this hardware (extra
monitors, an app dragged out of its workspace, a cold boot before plugins load).

Write these to `/tmp` and delete them when the question is answered. **Do not commit them** — they
encode matcher lists and bind names verbatim, so they rot the moment the config is edited, and there
is no CI to notice. This is a debugging instrument, not a test suite.

The whole recipe, which takes a couple of minutes to rebuild:

```lua
-- Any hl.dsp.a.b(opts) becomes an inspectable { kind = "a.b", opts = opts }
local function dsp(prefix)
  return setmetatable({}, { __index = function(_, k)
    local path = prefix == "" and k or prefix .. "." .. k
    return setmetatable({}, { __call = function(_, o) return { kind = path, opts = o } end,
                              __index = dsp(path) })
  end })
end

local binds, log = {}, {}
hl = {
  dsp = dsp(""),
  bind = function(keys, action) binds[keys] = action end,   -- CAPTURE, don't run
  dispatch = function(x) assert(x ~= nil, "dispatch got nil") log[#log+1] = x end,
  exec_cmd = function(c) log[#log+1] = { kind = "exec_cmd", opts = c } end,
  workspace_rule = function(r) log[#log+1] = r end,
  on = function(event, fn) binds[event] = fn end,           -- capture event handlers too
  define_submap = function(_, fn) fn() end,                 -- or redirect into a sub-table
  config = function() end, notification = { create = function() end },
  get_windows = function() return state.windows end,
  get_monitors = function() return state.monitors end,
  -- ...whatever else the file under test calls
}
dofile("dot_config/hypr/lua/keybindings.lua")
binds["SUPER+D"]()            -- now assert on `log`
```

Two things that decide whether this is worth anything:

- **Capture, then invoke.** `hl.bind` storing the function is what makes closures reachable;
  `hl.on` likewise, so `monitor.layout_changed` handlers can be fired by hand.
- **Mock fidelity is the whole ballgame.** A stub that returns what you *assume* upstream returns
  will cheerfully pass broken code — this happened for real with the scrolloverview plugin (§6g),
  where the stub returned a value but the plugin returns nothing inside a keybind. Read the upstream
  source for the contract, mirror *both* branches when behaviour is context-sensitive, and assert the
  negative (`dispatch` never receives `nil`).

### Checking cross-file matcher drift

An app's class is spelled twice: as a Hyprland regex in `rules.lua` (which places the window) and as
a Lua pattern in `keybindings.lua` (which finds it again). Editing one and not the other gives an app
that lands on a special workspace its keybind cannot find. After touching either list, compare them:

```bash
grep -oE '"\^[^"]+"' dot_config/hypr/lua/keybindings.lua | tr -d '"' | sed 's/%//g'
grep -oE 'class = "[^"]+"' dot_config/hypr/lua/rules.lua
```

Real instance: the password workspace listed ten apps in `rules.lua` but six in `keybindings.lua`, so
Enpass/KWalletManager/Seahorse/Secrets would open there and `SUPER+P` would spawn a second KeePassXC
instead of revealing them.

---

## 2. This is a chezmoi source directory, not live config

`/home/massimiliano/.local/share/chezmoi` is the *source*. Nothing edited here takes effect until
applied. The live files are in `$HOME`.

Source-name mangling matters when hunting for a file:

| Source path | Applies to |
|---|---|
| `dot_config/hypr/lua/rules.lua` | `~/.config/hypr/lua/rules.lua` |
| `dot_local/bin/executable_install-webapp` | `~/.local/bin/install-webapp` (chmod +x) |
| `dot_config/private_Code/` | `~/.config/Code/` (no group/world perms — 0700 dir, 0600 file) |
| `*.tmpl` | rendered through Go templates with `.chezmoi` data |
| `.chezmoiscripts/run_*` | not applied — *executed* (§3) |

Root-level files (`README.md`, `CLEANUP.md`, this file) are excluded from applying by the leading `*`
in `.chezmoiignore`, so they stay repo-only. New root files need no ignore entry.

### Hard rules

- **Never edit files under `$HOME` directly.** Every change goes into the source tree, then through
  `chezmoi apply`. A manual `$HOME` edit is silently reverted on the next apply, and worse, it makes
  the source lie about the system state.
- **Never poke around inside installed packages, plugin internals, or other programs' private state
  to figure something out.** The user has stated this explicitly and it is a standing constraint.
  When stuck, read documentation (§7) — do not reverse-engineer by rummaging through their machine.
- **Removing a file from the source does NOT delete the applied copy in `$HOME`.** A `git rm` needs a
  matching manual `rm`. Conversely, deleting only the live file achieves nothing — the next apply
  recreates it. This trips people up constantly; it's why `CLEANUP.md` opens with it.
- **Do not touch these** — they are owned by other software:
  - `dot_config/hypr/noctalia/` — regenerated by the noctalia package
  - `dot_config/hypr/lua/colors.lua` — generated by noctalia from `colors-template.lua`; ignored in
    `.chezmoiignore`, do not add it to git
  - `dot_config/hypr/xdph.conf` — `xdg-desktop-portal-hyprland`'s config, unrelated program
  - `dot_config/nvim/lua/matugen.lua`, `dot_config/ghostty/themes/` — same pattern, theme output
- **`dot_config/noctalia/user-templates.toml` is shared between Noctalia v4 and v5.** It generates
  the Hyprland border colours, so it must survive any future v4 purge (`CLEANUP.md` §2).

---

## 3. The install pipeline

Understanding this requires reading `.chezmoiscripts/`, `.chezmoitemplates/` and
`.chezmoiexternal.toml` together, so here is the shape.

### Ordering

chezmoi runs `before_` scripts, then applies regular files, then runs `after_` scripts. The numeric
prefixes order scripts *within* each phase, and the two sequences are independent:

- `before`: `01-cachyos-checks` → `02-apps-core` → `02-apps-coding` → `02-apps-ai` → `02-apps-media` →
  `02-apps-office` → `02-apps-communication` → `03-fonts-emoji` → `04-hyprland-noctalia`. Order
  *within* the `02-apps-*` group doesn't matter — none of the categories depend on packages installed
  by another, and `paru`/`pacman -S --needed` are idempotent regardless of run order.
- `after`: `01-system-services` → `03-sddm-PAM` → `04-sddm-themes` → `05-misc` →
  `06-gaming` → `07-webapps` → `08-tailscale` → `09-nordvpn` → `10-mega` → `11-finalize` →
  `12-hyprland-plugins` → `99` (hyprpm update). There is deliberately no `02-*` here — the old GRUB
  theme-sanitizer script was retired in favor of a manual README recipe (its `grep`/`sed` patterns
  hardcoded CachyOS's current `/etc/default/grub` layout and would silently no-op if that layout
  ever changed), and the gap in numbering was left as-is rather than renumbering every later script.
  `10-mega` was inserted between NordVPN and finalize, which is why finalize/hyprland-plugins sit at
  `11`/`12` rather than `10`/`11`.

The `run_once_` / `run_onchange_` / bare `run_` prefix decides *when*: once ever, on content change,
or every apply. **Renaming a script or editing an `onchange` one re-triggers it** — that is the
intended mechanism for "reinstall these packages", but it also means a cosmetic edit to a script
causes a real reinstall on the next full apply. Say so when you make one.

### Shared shell library

Every script opens with `#!/bin/bash`, `set -euo pipefail`, then includes the shared templates.
Follow that pattern; don't redefine what's already provided:

```bash
{{ template "utils.sh.tmpl" . }}
{{ template "external_links.sh.tmpl" . }}
```

- `utils.sh.tmpl` — logging (`info`, `success`, `warn`, `error`), `ask <question>` (Y/n prompt,
  Enter = yes), `reset_chezmoi_data_secret <key> <reminder>` (blanks a secret out of the user's
  `chezmoi.toml` after use), and `detect_gpu_vendor` which sets `GPU_VENDOR` to `nvidia`/`amd`/`""`.
  `detect_gpu_vendor` is a **pure vendor check only** — it does not know whether the specific card is
  ROCm-supported (ROCm's hardware support list is a narrow, moving allowlist, not something worth
  hardcoding here). `run_onchange_before_02-apps-ai.sh.tmpl` compensates by `ask`-ing before
  installing `rocm-hip-sdk` on any AMD GPU, defaulting (Enter) to skipping ROCm and falling back to
  CPU-only Ollama — installing ROCm packages on an unsupported architecture (e.g. Polaris/gfx803, RX
  400/500 series) has caused total display-output loss on at least one machine.
- `external_links.sh.tmpl` — **all** external download URLs, versions and SHA256 hashes, as shell
  variables with "last checked" dates. When an upstream asset moves, edit this file; never inline a
  URL into a script.

### Template data

Scripts gate on the user's `~/.config/chezmoi/chezmoi.toml` `[data]` block: `.name`, `.email`,
`.gaming` (skip Steam/OpenRGB/etc.), `.coding` (skip dev tooling), `.ai` (skip
CUDA/ROCm/Ollama/Claude Code/Antigravity/OpenCode entirely), `.media` (skip
kdenlive/OBS/EasyEffects/Spotify/yt-dlp/image-upscaler), `.office` (skip
LibreOffice/KeePassXC/qBittorrent/etc.), `.communication` (skip
Telegram/Signal/Discord/Element/LocalSend) — each one gates its own `02-apps-*` script (§3
Ordering). `.tailscale_authkey` / `.nordvpn_token` / `.mega_authkey` are three-state: boolean `false`
(or the string `"false"`) skips installing that integration entirely; `""` installs and enables it
but skips auto-login; any other string is used as the actual key/token to log in with. The
install/enable block is gated by `{{- if ne (printf "%v" .field) "false" }}` (stringified with
`printf "%v"` since Go templates panic comparing a bool to a string directly with `ne`/`eq`), and the
login sub-block nested inside it is gated by the simpler `{{- if .field }}` (empty string is already
falsy in Go templates, and `false` is excluded by the outer branch). Several scripts also branch on
`{{- if ne .chezmoi.osRelease.id "cachyos" }}` to install what CachyOS would otherwise have
provided. New optional features should follow the same "empty/false means skip cleanly" convention.

**Chezmoi errors out, rather than defaulting to empty, if a `[data]` key referenced by a template
doesn't exist at all** — so adding any new `.field` here requires the user to add it to
`~/.config/chezmoi/chezmoi.toml` (not just leave it unset) before their next apply, same as every
existing key in this list.

`10-mega` (`run_once_after_10-mega.sh.tmpl`) follows the tailscale/nordvpn pattern exactly, using a
MEGA **session id** (obtained once via `mega-login <email>` then `mega-session`) as `.mega_authkey`
rather than a raw account password — avoids storing a plaintext password in chezmoi.toml. Unlike
NordVPN/Tailscale, MEGA is **not** gated by `.office` even though it's office-adjacent — it mirrors
NordVPN/Tailscale's independence from any category flag instead. `megacmd` used to be installed
unconditionally under `02-apps-office`, so existing users must add `mega_authkey` (even as `false`,
to preserve "don't manage MEGA login") to `chezmoi.toml` before their next apply, per the point above.

### Externals

`.chezmoiexternal.toml` pulls wallpapers, propics (`~/.face`, `~/.logo`), the SDDM theme and the
Bibata hyprcursor from the user's `nMaax/dotfiles-assets` and `nMaax/dotfiles-sddm` repos, with a
168h `refreshPeriod`. Large binary assets live there, **not** in this repo.

**Always `chezmoi add --exclude=externals`, never a bare `chezmoi add .`/`chezmoi add .config
.local`.** These six targets are fetched content, not meant to be duplicated as literal source
files, and a plain recursive `add` that walks into one of their directories hits a real chezmoi
bug (upstream issue #1574: `add` crashes with `stat ...: no such file or directory` when it
recurses into a directory an external created) instead of cleanly skipping it. `--exclude=externals`
(plural — `external` singular is rejected as an unknown entry type) sidesteps this categorically,
independent of `.chezmoiignore`.

`.chezmoiignore`'s root-level `*` blanket-excludes everything except `.config/` and `.local/` by
default (§2 has the full mangling table) — every external target outside those two trees needs an
explicit `!` exception plus, if it's a directory, an immediate re-narrowing back down to just that
target (mirroring the existing `.local/share/applications` / `.config/OpenRGB/...` pattern), or it
silently never gets fetched. This bit real: `.face`/`.logo` were missing from `$HOME` entirely
because they'd never been un-ignored, which is also why fastfetch fell back to the CachyOS ASCII
logo instead of `~/.logo`.

### `--needed` doesn't know about package providers — use `pacman -T` before forcing a name

Real incident, found in `/var/log/pacman.log`: this machine had `nodejs-lts-krypton` installed
manually (alongside `pnpm`, unrelated to these scripts) months before a `chezmoi apply`.
`nodejs-lts-krypton` `Provides: nodejs=X` (so `npm`/`pyright`'s `Depends On: nodejs` was already
satisfied) but also `Conflicts: nodejs`. `run_onchange_before_02-apps-coding.sh.tmpl` asked pacman
for the literal `nodejs` package; `--needed` only skips a package already installed **under that
exact name**, so it didn't skip, pacman hit the conflict, and — because `--noconfirm` doesn't cover
conflict-resolution removals — the scripted `--noconfirm` transaction failed outright under
`set -euo pipefail`, requiring the user to manually run `pacman -S nodejs` to resolve it themselves.

The fix (and the pattern to reuse anywhere a script names a package that has known alternative
providers): check `pacman -T <pkg>` first — it exits 0 silently if the dependency is already
satisfied by *anything* (the named package or a provider), and prints the name with a non-zero exit
if not. This is future-proof against new provider names (e.g. a future `nodejs-lts-*` codename)
without hardcoding a list. See `run_onchange_before_02-apps-coding.sh.tmpl` for the guarded
`nodejs` install.

### btop/nvtop show no AMD GPU stats without `rocm-smi-lib`

`pacman -Si btop` lists it as an optional dep ("AMD GPU support") — without it, btop/nvtop can't read
AMD GPU usage/VRAM/temperature at all. It depends on `hsa-rocr`/`rocm-core` (the base HSA runtime),
which is much lighter than the `rocm-hip-sdk`/`rocm-opencl-runtime`/`hip-runtime-amd` trio that caused
the display blackout documented in the AI-tools section — but it's still ROCm-adjacent, so
`run_once_before_01-cachyos-checks.sh.tmpl` gates it behind an `ask()` (default: install) rather than
adding it to the unconditional package list, same caution as the AI script's ROCm prompt.

### Setup facts that affect config code

- Login must be **systemd-owned Hyprland (UWSM)** in SDDM, or autostart entries (tray icons, agents)
  misbehave. `dot_config/hypr/lua/autostart.lua` assumes it.
- KWallet is the keyring, and PAM auto-unlock only works for a wallet literally named `kdewallet`
  with Blowfish encryption and the login password. `autostart.lua` execs `pam_kwallet_init`.
- `dot_local/bin/` holds the helper scripts the config calls (`install-webapp`, `launch-webapp.sh`,
  `spicetify-setup.sh`).
- `dot_config/fish/functions/` is a large library of one-purpose media/document conversion functions
  (`pdf-*`, `vid2*`, `*2png`, …). Self-contained; add new ones as single files following the
  existing naming.

---

## 4. Hyprland Lua config

`hyprland.lua` is loaded **instead of** `hyprland.conf` when it exists — checked once at startup, not
merged. The legacy `hyprland.conf` and `hyprland/*.conf` were removed per `CLEANUP.md` §1 (both
source and live copies) once the Lua config proved itself; there is no `.conf` fallback anymore.

`require("lua.foo")` replaces `source =`, resolved relative to `~/.config/hypr/`. Module order in
`hyprland.lua` mirrors the old source chain.

| Module | Holds |
|---|---|
| `autostart.lua` | `hl.on("hyprland.start", ...)` execs |
| `env.lua` | `hl.env()` |
| `permissions.lua` | entirely commented out, nothing active |
| `monitors.lua` | `hl.monitor()`, `hl.workspace_rule()` |
| `lookandfeel.lua` | `hl.config` for general/decoration/animations/layouts. **No perf settings** |
| `input.lua` | keyboard/touchpad/per-device |
| `keybindings.lua` | all `hl.bind()`, plus the native Lua helper closures |
| `rules.lua` | `hl.window_rule()`, `hl.layer_rule()` |
| `plugins.lua` | plugin *options* only — loading stays with `hyprpm` |
| `performance.lua` | latency/rendering tuning |
| `misc.lua` | the `misc` block |

Setters: `hl.config`, `hl.bind`, `hl.monitor`, `hl.workspace_rule`, `hl.window_rule`, `hl.layer_rule`,
`hl.curve`/`hl.animation`, `hl.device`, `hl.gesture`, `hl.env`, `hl.exec_cmd`, `hl.on`,
`hl.define_submap`, `hl.dispatch`, `hl.notification.create`, `hl.timer`.

Queries (all verified live): `hl.get_config(key)`, `hl.get_windows(filters)` — includes windows on
*hidden* special workspaces, which is what makes the special-workspace toggle work —
`hl.get_active_workspace()`, `hl.get_workspace_windows(id)`, `hl.get_active_window()`,
`hl.get_workspaces()`. An `HL.Window` exposes `class`, `title`, `initial_class`, `initial_title`,
`address`, `workspace`, `pid`.

Two capabilities justify the migration off hyprlang:

- **`hl.bind` accepts a plain Lua function.** This is how `hypr-scrolling.sh` and `hypr-toggle.py`
  became in-process closures (`toggle_ws`, `move_workspace_windows` in `keybindings.lua`) with no
  shell round-trip.
- **`hl.config` works at runtime**, not just at load. `SUPER+X` flips `general.layout` between
  `scrolling` and `dwindle` by reading `hl.get_config` and writing `hl.config` back.

---

## 5. Noctalia v5

**Invariant: Hyprland Lua ⟺ Noctalia v5; Hyprland `.conf` ⟺ Noctalia v4.** Both are installed, v4 as
a fallback (they don't conflict — v4 is JSON at `~/.config/noctalia/`, v5 is TOML at
`~/.local/state/noctalia/`). We use Lua + v5. Do not mix.

- IPC is `noctalia msg <command>`, and **`noctalia msg --help` is authoritative** — prefer it over
  the docs. `keybindings.lua` wraps it in a local `ipc()` helper.
- **v5 settings: only `settings.toml` is tracked**, at `dot_local/private_state/noctalia/settings.toml`
  (`private_` because `~/.local/state` is 0700). Everything else there — history, usage stats,
  downloaded caches, plugin build output — stays untracked via `.chezmoiignore`.
- **Plugin IDs are `<author>/<plugin>:<entry>`.** Panels: `panel-toggle noctalia/mpvpaper:picker`.
  Events: `plugin <author/plugin:entry> <target[:bar]> <event> [payload]`, target `all` for singleton
  services. Enumerate what's installed with `noctalia msg plugins list` — the v4 directory names
  under `~/.config/noctalia/plugins/` are **not** valid v5 IDs (all five were wrong initially, and
  all five omitted the `:entry` half).
- **Not every plugin is a panel.** Kaomoji is a *launcher provider*, reached as
  `panel-toggle launcher "/kao"`. Bongo Cat has no panel at all. Providers use the
  `shell.launcher.provider_prefix` char: `/emo`, `/kao`, `/calc`, `/wall`, `/session`, `/win`.
- **Not every plugin has IPC.** W Engine has no handler, so its kill path is
  `pkill -f linux-wallpaperengine` alongside mpvpaper's real `clear-all` event.
- Screenshots use Noctalia native (`screenshot-region`,
  `screenshot-fullscreen [pick|monitor|all]`). There is **no per-window** mode — `pick` picks a
  monitor. `hyprshot` is consequently unused and listed for removal; if per-window capture is ever
  wanted back, hyprshot has to stay.

### Webapps

`dot_local/bin/executable_install-webapp` creates chromium `--app=` desktop entries. Chromium derives
the Wayland app_id as `chrome-<host><path with / → _>-Default`. Confirmed live:
`chrome-gemini.google.com__app-Default`, `chrome-claude.ai__-Default` (an empty path still yields
`__`). Match these **prefix-anchored and per-host** — a blanket `^chrome-.*-Default$` would drag
WhatsApp, ddocs and MCHOSE HUB into whatever workspace you're scoping.

For terminal tools, `ghostty --class=<id> -e <cmd>` sets a deterministic app_id (ghostty exposes any
config key as a CLI flag), far more robust than matching volatile terminal titles. Verified live:
`ghostty --class=ai.claude` really does produce class `ai.claude`, and a workspace rule then picks it
up unaided. The AI CLIs it was introduced for turned out to work badly on a special workspace and are
opened by hand now, but the sysmon workspace (`SUPER+Delete` → btop) uses exactly this pattern —
class `sysmon.btop`, matched in both `keybindings.lua` and `rules.lua` — after title matching proved
unreliable (ghostty's title only updates after the window is already mapped, too late for an
open-time workspace rule).

---

## 6. Gotchas that cost real time

1. **Hyprland registers duplicate keybinds silently.** No `configerrors` entry, no warning — both
   exist and one shadows the other. *Always* sweep after adding binds:
   ```bash
   hyprctl binds -j | jq -r '.[]|"\(.modmask)|\(.key)|\(.submap)"' | sort | uniq -d
   ```
   Anything printed is a conflict. This caught a real one (Antigravity landed on the media panel's
   `SUPER+ALT+A`).

2. **Dispatcher constructors do not validate option keys.**
   `hl.dsp.window.move({workspace=..., bogus=1})` constructs happily. Option names can only be
   confirmed by actually dispatching — a clean load is not evidence that an option name is right.

3. **Lua patterns are not regex.** No `|` alternation; `.` must be escaped `%.`. And the two files
   use *different* conventions:
   - `rules.lua` matchers are Hyprland **regex** → `chrome-claude\\.ai`
   - `keybindings.lua` matchers are **Lua patterns** → `^chrome%-claude%.ai`

   Same concept, two escapings, same repo. Check which file you're in.

4. **Binds are positional, not layout-dependent.** `input.resolve_binds_by_sym = false` is pinned in
   `input.lua` (Hyprland's default, pinned deliberately with a comment). Each bind's keysym maps to a
   keycode via the **first** `kb_layout` (`us`), then matching is by keycode — so every bind fires on
   the same physical key whether `us` or `it` is active. **Write binds in US keysyms.** Setting the
   option `true` would relocate every punctuation bind. This is why `SUPER+slash` works as `?` on
   both layouts, and why resize uses `Minus`/`Equal` (the `Plus` variants were duplicate keycodes and
   were deleted).

5. **`pkill -f <pattern>` matches its own shell's command line** and kills the shell (exit 144,
   truncated output). Use the bracket trick: `pkill -f 'mark[e]r'`.

6. **`hyprctl eval` only prints `ok`** — see §1 for the scratch-file workaround.

6b. **`hyprctl dispatch <dispatcher>` does not work under the Lua config.** The argument is parsed as
   *Lua* (`hyprctl dispatch workspace 2` → `hl.dispatch(workspace 2)` → syntax error), and Hyprland
   says so in the error: "dispatch in lua is a shorthand for hl.dispatch(...)". Failures are easy to
   miss when you don't read the output, so nothing happens and you think it worked. Use
   `hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "2" }))'` instead.

   The same trap applies *inside* the config: any bind built as
   `hl.dsp.exec_cmd("hyprctl dispatch ...")` is dead on arrival. This silently broke every
   scrolloverview bind for the entire hyprlang-to-Lua transition — the plugin was loaded and the
   binds were registered, they just never did anything.

6g. **Plugin dispatchers live at `hl.plugin.<name>.<dispatcher>(arg)`**, not behind `hyprctl`. They
   return an ordinary dispatcher, exactly like `hl.dsp.*`, so
   `hl.dispatch(hl.plugin.scrolloverview.overview("toggle"))` works and reports `{ ok = true }`.
   Enumerate what a loaded plugin offers with
   `hyprctl eval 'for k in pairs(hl.plugin.<name>) do ... end'`; `hl.get_loaded_plugins()` lists names.

   **Resolve it lazily, inside the bind's function.** `hyprpm` loads plugins from `autostart.lua`, so
   at config-parse time on a cold boot `hl.plugin.<name>` is still `nil` and indexing it eagerly
   aborts the entire config. `keybindings.lua`'s `scrolloverview()` helper shows the pattern.

   **These factories are context-sensitive, and this is a genuine trap.** Called from *inside* a Lua
   keybind callback, the plugin runs the dispatcher **immediately and returns nothing**; called
   anywhere else (config parse, `hyprctl eval`) it returns a bind-action function and runs nothing.
   So `hl.dispatch(plugin.overview("toggle"))` inside a bind passes `nil` and warns "expected a
   dispatcher" *after* the action has already fired. Either pass the factory result straight to
   `hl.bind` at parse time, or call it inside the callback and invoke the result only
   `if type(action) == "function"`. Verified in scrolloverview's `Config.cpp:dispatcherFactoryLua`.

   Consequence for testing: `hyprctl eval` is **not** a keybind context, so a plugin call that works
   there can still be wrong in a bind. This defeated a full round of my own testing. When mocking a
   plugin in the stubbed-`hl` harness, mirror both branches and `assert` that `hl.dispatch` is never
   handed `nil`.

6h. **`hl.dsp.exec_raw` is not a dispatcher runner** — it `spawnRaw`s a process (exec without a
   shell). For "re-apply my monitors" the dispatcher is `hl.dsp.force_renderer_reload()`; note
   `monitor` is a config *keyword*, never a dispatcher.

6c. **Workspace window rules are evaluated on window *open* only.** A window moved out of its special
   workspace afterwards stays out — verified by moving a rule-matched window to workspace 7 and
   watching it remain. That's what makes manual placement overridable, and it's why the throw-in
   binds (`SUPER+SHIFT+<key>`) can park *any* app in a special workspace and have it stick.
   Corollary: an app that closes to tray and reopens gets the rule applied afresh.

6d. **`hl.dsp.focus({ window = w })` reveals a hidden special workspace** as it focuses, and there is
   no `hl.dsp.window.focus` — focusing is always `hl.dsp.focus`. That single call is what lets a
   keybind reach an app whether it's tucked away or dragged out somewhere else.

6e. **`m[N]` is a *workspace* selector, not a monitor identifier.** A workspace rule's `monitor` field
   takes a monitor name or `desc:...`. Passing `m[1]` fails to resolve *silently*: the workspace loses
   its pin but keeps `persistent`, so it gets created on whatever monitor happens to exist. This was a
   real bug in `monitors.lua` for the whole hyprlang era.

6f. **A workspace rule's `monitor` cannot be un-set.** Re-issuing the rule with `monitor = ""` leaves
   the previous monitor in place — rules merge rather than replace for that field. `persistent` *does*
   update, and dropping it destroys the empty workspace. So to "unpin", assign the monitor you do want
   rather than trying to clear it; `monitors.lua` pins everything to the sole monitor when there's
   only one, which is equivalent and never leaves a rule naming a disconnected output.

### Editor support for the `hl` global

Hyprland ships autogenerated LuaLS stubs at **`/usr/share/hypr/stubs/hl.meta.lua`** (1770 lines,
`---@meta`, declares `hl = {}` plus every `HL.*` class and the `HL.EventName` alias). Loading them
gives real field-level checking — `hl.bnid(...)` is reported as an undefined *field*, and event-name
strings are validated — not merely silence.

They are wired up by **`.luarc.json` in the hypr config directory**, which exists twice on purpose:

- `dot_config/hypr/dot_luarc.json` → applied to `~/.config/hypr/.luarc.json`, for editing the live config
- `dot_config/hypr/.luarc.json` → a literal dotfile in the *source* tree, for editing the files here.
  chezmoi ignores source entries starting with `.`, so it never becomes a target. Keep the two in sync.

Both are needed because `.luarc.json` must sit at the lua_ls *workspace root*, and this repo is edited
directly. It goes in `dot_config/hypr/` rather than `dot_config/hypr/lua/` so that `hyprland.lua` is
covered too.

Why this placement is safe on nvim 0.12: `nvim-lspconfig`'s `lua_ls` puts `.luarc.json` in its
**highest-priority** root-marker group, above `.git` — so it wins over the chezmoi repo root. And
`dot_config/hypr/` is not an ancestor of `dot_config/nvim/`, so nvim's own Lua (lazydev, the `vim`
global) is structurally unaffected.

Verify with the mason-installed binary, pointing it at the directory holding `.luarc.json` — aiming it
at `lua/` instead makes *that* the root and the config is missed:

```bash
~/.local/share/nvim/mason/bin/lua-language-server --check dot_config/hypr --checklevel=Warning
```

Expect "no problems found"; without the config it reports 335.

### Testing multi-monitor behaviour without extra hardware

`hyprctl output create headless <NAME>` adds a virtual monitor and `hyprctl output remove <NAME>`
takes it away — the same mechanism upstream's own test suite uses. Both fire
`monitor.layout_changed`, so this exercises real add/remove code paths, including the drop back to a
single monitor. Note a headless output reports `physical_width/height = 0`, which conveniently also
exercises any EDID-missing fallback. Combine with a stubbed-`hl` harness (§1) for the geometry cases
a headless output can't produce, such as two equal-sized monitors differing only in position.

7. **`change_id` (Hyprland 0.56) cannot target workspaces 1–10 here.** It rejects an already-occupied
   target id, and `monitors.lua` declares 1–10 `persistent = true`, so all ten always exist. The
   move-whole-workspace feature (`SUPER+ALT+<digit>`) therefore moves each window individually.
   `change_id` remains the right tool for *stashing* a layout at an unused high id.

8. **`scrolling.column_width` was tried at `1.0`** (niri-like full-width-then-scroll) **and reverted
   back to upstream's `0.5` default** — two windows now sit side-by-side as half-width columns again.
   `K`/`J`/`SHIFT+K`/`SHIFT+J` in `keybindings.lua` do in-workspace focus/move first and only fall
   back to workspace-scroll at the edge (the `smart_focus`/`smart_move` closures), so column_width no
   longer needs to compensate for K/J being workspace-scroll-only. `fit_into_view`, `fit active` and
   `inhibit_scroll` are **layout messages**, not config options — they go through `hl.dsp.layout(...)`,
   not `hl.config`.

---

## 7. Where to find answers

- **`hyprctl descriptions`** — enumerates every config option with `name`, `description`, `default`,
  `current`, `min`, `max`, `map`. The key is `name`, not `value`. More reliable than the wiki for
  defaults and for confirming an option exists in the *installed* version.
- **`hyprctl binds -j`**, **`hyprctl clients -j`**, **`hyprctl workspacerules`** — verify what
  actually registered.
- **The Hyprland wiki cannot be fetched** — JS-rendered, WebFetch returns only navigation. Use
  `hyprctl descriptions`, `gh release view vX.Y.Z -R hyprwm/Hyprland`, and `gh pr view <n>` on the
  individual PRs. PR bodies and test cases are excellent primary sources (that's how `change_id`'s
  occupancy restriction was found).
- **`noctalia msg --help`** and `docs.noctalia.dev`; `noctalia.dev/plugins/...` or a plugin's upstream
  GitHub for its syntax.
- **`chezmoi doctor`** and `chezmoi.io/reference` for chezmoi semantics.

---

## 8. Deferred work — do not start without asking

Known, deliberate TODOs. Non-trivial, and the user wants to scope them:

- `monitors.lua` — dynamic monitor detection / primary switching when the external display connects
- `input.lua` — conditional per-device input config
- `performance.lua` — competitive-gaming latency tuning
- `keybindings.lua` (~line 137) — split the communication workspace per app (telegram / discord /
  whatsapp separately)

`README.md` also carries a user-facing TODO list; those are the user's own project ideas, not work
queued for Claude.

Also: the user edits these files between sessions. If something looks like it regressed (binds you
remember are gone), assume it was intentional and ask — do not restore it.

---

## 9. Conventions

> **Comments: max 1-2 lines, always.** Explain *why* (a pinned option, an empirically-discovered
> gotcha), never *what* the code does. No mechanism narration, no listing every file/case it touches —
> that belongs in the diff or commit message. If a comment runs past 2 lines, cut it, don't wrap it.
> This applies to every file type in this repo: Lua, bash, TOML, everywhere.

- Tabs for indentation in the Hyprland Lua files. (`dot_config/nvim/stylua.toml` specifies 2 spaces,
  but it governs the *nvim* tree only — don't apply it here.)
- Shell scripts: `#!/bin/bash`, `set -euo pipefail`, shared templates included, user-facing output
  through `info`/`success`/`warn`/`error` rather than bare `echo`.
- `description` on `hl.bind` is what the keybind-cheatsheet plugin displays, so it doubles as user
  documentation. Convention is one description per *group*, not per bind: repetitive binds are left
  bare and the last member carries a collapsed label — `SUPER+1`…`SUPER+9` are undescribed and
  `SUPER+0` says `"Access workspace [0-9]"`. Media/`XF86*` keys and submap navigation binds are
  deliberately undescribed (self-evident, and they'd flood the sheet). Anything genuinely new and
  discoverable gets its own.
- `git commit` messages are one-liners listing the changes, not verbose bodies.
