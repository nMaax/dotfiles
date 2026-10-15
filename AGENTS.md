# AGENTS.md

Guidance for coding agents working in this repository. `CLAUDE.md` is a symlink to this file.

Personal dotfiles for a **CachyOS + Hyprland + Noctalia** desktop, managed with
[chezmoi](https://www.chezmoi.io/). There is no build system, no test suite and no CI — the
"application" is the user's machine, and the closest thing to a test run is `chezmoi apply` followed
by asking the affected program whether it is happy.

---

## 1. Commands

### chezmoi

```bash
chezmoi diff                      # what would change in $HOME
chezmoi status                    # short form; see the 12-hyprland-plugins.sh note below
chezmoi apply --exclude=scripts   # DEFAULT for config work: regular files only
chezmoi apply                     # full run, EXECUTES install scripts (sudo prompts) -- user's call
chezmoi add --exclude=externals <target>   # DEFAULT when re-adding config drift
chezmoi cat <target>              # render one file as it would be applied
chezmoi execute-template < .chezmoiscripts/run_onchange_after_07-webapps.sh.tmpl
chezmoi doctor                    # environment sanity
```

**Agents have no TTY, so anything that prompts hangs or fails.** Safe without input: `diff`, `status`,
`cat`, `execute-template`, `doctor`, `add --exclude=externals`, and `apply --exclude=scripts`.
Not safe:

- `apply` / `update` without `--exclude=scripts` — `01-cachyos-checks` asks Y/n every run and the
  install scripts call `sudo` (password) and `paru`. Leave these to the user (`! chezmoi apply`).
- `apply` onto a target edited since chezmoi last wrote it — chezmoi prompts overwrite/skip. Read
  `chezmoi diff` first; only the user decides on `--force`.
- `update` = `git pull` + `apply`, so it inherits both problems, plus network (externals, git auth).
- `init` — prompts for `[data]` values.

`chezmoi execute-template` is the way to test a `.tmpl` change: it renders the template, including
`{{ template "utils.sh.tmpl" . }}` inclusions, **without executing** anything. Use it on scripts
rather than running them.

`chezmoi status` will essentially always show `R .chezmoiscripts/12-hyprland-plugins.sh` pending, and
`chezmoi verify` will exit 1 because of it. That is expected, not a problem:
`run_after_12-hyprland-plugins.sh.tmpl` has neither `once` nor `onchange` in its name, so it is due
on *every* apply, and `--exclude=scripts` never runs it. Ignore that one line; investigate anything
else.

### Validating changes

There are no linters installed (no `shellcheck`, `stylua`, `luacheck`) — don't reach for them.
Validation is per-subsystem:

```bash
# Hyprland Lua -- syntax
luac5.4 -p dot_config/hypr/lua/*.lua && chezmoi cat ~/.config/hypr/hyprland.lua | luac5.4 -p -

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
luac5.4 -p dot_config/hypr/lua/*.lua && chezmoi cat ~/.config/hypr/hyprland.lua | luac5.4 -p -   # 1. syntax
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

### Special-workspace app classes

An app's class must be matched twice: as a Hyprland regex in `rules.lua` (places the window) and as a
Lua pattern in `keybindings.lua`/`gaming.lua` (finds it again). Both are generated from the single plain
list in `constants.lua` (`C.APP_CLASSES`, `C.MUSIC_TITLES`, `C.GAMES_TITLES`) by `special.regex` /
`special.patterns`, so they cannot drift. Add or remove an app **only** there; a trailing `*` means
"starts with" (the `chrome-<host>` webapp ids). Names are literals, so write `Spotify` and `spotify`,
not `[Ss]potify`.

Real instance of the drift this replaced: the password workspace listed ten apps in `rules.lua` but six
in `keybindings.lua`, so `SUPER+P` spawned a second KeePassXC instead of revealing the others.

---

## 2. This is a chezmoi source directory, not live config

`/home/massimiliano/.local/share/chezmoi` is the *source*. Nothing edited here takes effect until
applied. The live files are in `$HOME`.

Source-name mangling matters when hunting for a file:

| Source path | Applies to |
|---|---|
| `dot_config/hypr/lua/rules.lua` | `~/.config/hypr/lua/rules.lua` |
| `dot_local/bin/executable_install-webapp.tmpl` | `~/.local/bin/install-webapp` (chmod +x) |
| `dot_config/private_Code/` | `~/.config/Code/` (no group/world perms — 0700 dir, 0600 file) |
| `*.tmpl` | rendered through Go templates with `.chezmoi` data |
| `.chezmoiscripts/run_*` | not applied — *executed* (§3) |

Root-level files (`README.md`, this file) are excluded from applying by the leading `*`
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
  recreates it.
- **Do not touch these** — they are owned by other software:
  - `dot_config/hypr/noctalia/` — regenerated by the noctalia package
  - `dot_config/hypr/lua/colors.lua` — generated by noctalia from `colors-template.lua`; ignored in
    `.chezmoiignore`, do not add it to git
  - `dot_config/hypr/xdph.conf` — `xdg-desktop-portal-hyprland`'s config, unrelated program
  - `dot_config/nvim/lua/matugen.lua`, `dot_config/ghostty/themes/` — same pattern, theme output
- **`dot_config/noctalia/user-templates.toml` is shared between Noctalia v4 and v5.** It generates
  the Hyprland border colours, so it must survive any v4 purge.

---

## 3. The install pipeline

Understanding this requires reading `.chezmoiscripts/`, `.chezmoitemplates/` and
`.chezmoiexternal.toml` together, so here is the shape.

### Ordering

chezmoi runs `before_` scripts, then applies regular files, then runs `after_` scripts. The numeric
prefixes order scripts *within* each phase, and the two sequences are independent:

- `before`: `01-cachyos-checks` (interactive prompts, every apply) → `01b-cachyos-packages` (prerequisites & base apps, once) → `02-apps-core` → `02-apps-coding` → `02-apps-ai-dev` → `02-apps-agents` → `02-apps-media` →
  `02-apps-office` → `02-apps-communication` → `03-fonts-emoji` → `04-hyprland-noctalia`. Order
  *within* the `02-apps-*` group doesn't matter — none of the categories depend on packages installed
  by another, and `paru`/`pacman -S --needed` are idempotent regardless of run order.
  CachyOS stopped shipping `paru` in June 2026, so `01b` installs it from the `cachyos` repo before any script calls it.
- `after`: `01-system-services` → `04-noctalia-greeter` → `05-misc` →
  `06-gaming` → `07-webapps` → `08-tailscale` → `09-nordvpn` → `10-mega` → `11-finalize` →
  `12-hyprland-plugins`. The `02-*`/`03-*` gap is deliberate (a retired GRUB script, now a README
  recipe); numbers were not reshuffled.

The `run_once_` / `run_onchange_` / bare `run_` prefix decides *when*: once ever, on content change,
or every apply. **Renaming a script or editing an `onchange` one re-triggers it** — that is the
intended mechanism for "reinstall these packages", but it also means a cosmetic edit to a script
causes a real reinstall on the next full apply. Say so when you make one.

### hyprpm plugin management

`run_after_12-hyprland-plugins.sh.tmpl` is the single place that installs, updates, enables and
reloads Hyprland plugins. Plugins live in a `name|repo_url` `HYPRPM_PLUGINS` bash array at the top —
add a line there (URL in `external_links.sh.tmpl`) rather than hand-rolling another install block.
Every apply adds missing plugins, runs `hyprpm update`, enables all, then `hyprpm reload -n` so the
running session picks them up.

When `hyprpm`'s cached build goes stale after a Hyprland bump (plugin load failures), run
`~/.local/bin/hyprpm-rebuild`: it purges the cache and re-runs the script above via
`chezmoi execute-template`. Manual on purpose — a plugin purge shouldn't fire silently on `chezmoi apply`.

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
  `detect_gpu_vendor` is a **pure vendor check** — it doesn't know if the card is ROCm-supported.
  `run_onchange_before_02-apps-ai-dev.sh.tmpl` therefore `ask`s before installing `rocm-hip-sdk` on
  AMD, defaulting to skip (CPU-only Ollama): ROCm on unsupported cards (e.g. Polaris/gfx803) has
  caused total display-output loss.
- `external_links.sh.tmpl` — **all** external download URLs, versions and SHA256 hashes, as shell
  variables with "last checked" dates. When an upstream asset moves, edit this file; never inline a
  URL into a script.

### Template data

Scripts gate on the user's `~/.config/chezmoi/chezmoi.toml` `[data]` block: `.name`, `.email`,
`.gaming` (skip Steam/OpenRGB/etc.), `.coding` (skip dev tooling), `.ai_dev` (skip CUDA/ROCm/Ollama),
`.agents` (skip Claude Code/Antigravity CLI/OpenCode), `.media` (skip
kdenlive/OBS/EasyEffects/Spotify/yt-dlp/image-upscaler), `.office` (skip
LibreOffice/KeePassXC/qBittorrent/CUPS printing etc.), `.communication` (skip
Telegram/Signal/Discord/Element/LocalSend) — each one gates its own `02-apps-*` script (§3
Ordering). `.plugins` gates `12-hyprland-plugins`, `require("lua.plugins")` and `hyprpm-rebuild`.
`.tailscale_authkey` / `.nordvpn_authkey` / `.mega_authkey` are three-state: boolean `false`
(or the string `"false"`) skips installing that integration entirely; `""` installs and enables it
but skips auto-login; any other string is used as the actual key/token to log in with. The
install/enable block is gated by `{{- if ne (printf "%v" .field) "false" }}` (stringified with
`printf "%v"` since Go templates panic comparing a bool to a string directly with `ne`/`eq`), and the
login sub-block nested inside it is gated by the simpler `{{- if .field }}` (empty string is already
falsy in Go templates, and `false` is excluded by the outer branch). Several scripts also branch on
`{{- if ne .chezmoi.osRelease.id "cachyos" }}` to install what CachyOS would otherwise have
provided. New optional features should follow the same "empty/false means skip cleanly" convention.

That file is generated by `chezmoi init` from `.chezmoi.toml.tmpl`, which prompts only for keys
missing from it (`prompt*Once`, or `hasKey` for the three-state authkeys). **Add every new `.field`
there**: chezmoi errors out, rather than defaulting to empty, on a missing key, and existing users
pick it up by re-running `chezmoi init`. Keep `,` and `=` out of prompt text — they break the
`--promptBool`/`--promptString` flags. Test with `chezmoi --config <empty file> execute-template
--init --promptBool '<prompt>=<value>,…' < .chezmoi.toml.tmpl`.

`.mega_authkey` is a MEGA **session id** (`mega-login <email>` then `mega-session`), not a password,
so no plaintext password sits in chezmoi.toml. MEGA follows the tailscale/nordvpn pattern and is
**not** gated by `.office`.

The polkit agent is `hyprpolkitagent` (`autostart.lua` execs `/usr/lib/hyprpolkitagent/hyprpolkitagent`,
installed by `run_onchange_before_02-apps-core.sh.tmpl`). Scripts never reference `polkit-kde-agent`
— no uninstall, no assumption it's present. An existing machine that still has it installed must
drop it by hand; confirm no duplicate agent runs.

### Externals

`.chezmoiexternal.toml` pulls wallpapers, propics (`~/.face`, `~/.logo`) and the Bibata hyprcursor
from the user's `nMaax/dotfiles-assets` repo, with a 168h `refreshPeriod`. Large binary assets live
there, **not** in this repo.

**Always `chezmoi add --exclude=externals`, never a bare `chezmoi add .`/`chezmoi add .config
.local`.** These five targets are fetched content, not meant to be duplicated as literal source
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

`--needed` only skips a package installed **under that exact name**. A machine with
`nodejs-lts-krypton` (`Provides: nodejs`, `Conflicts: nodejs`) hit a conflict on the literal `nodejs`
request, and `--noconfirm` doesn't cover conflict removals, so the whole script failed.

For any package with alternative providers, check `pacman -T <pkg>` first: it exits 0 if anything
satisfies the dependency. See the guarded `nodejs` install in `run_onchange_before_02-apps-coding.sh.tmpl`.

### Setup facts that affect config code

- Login must launch **systemd-owned Hyprland (UWSM)** — session name `Hyprland (uwsm-managed)` in
  the greeter's session picker — or autostart entries (tray icons, agents) misbehave.
  `dot_config/hypr/lua/autostart.lua` assumes it.
- KWallet is the keyring; PAM auto-unlock (when configured) only works for a wallet literally named
  `kdewallet` with Blowfish encryption and the login password. **Auto-unlock is currently not
  configured** (see Greeter below), so `autostart.lua` has no `pam_kwallet_init` exec; KWallet
  prompts once per session. If auto-unlock returns, that exec must come back too.
- `dot_local/bin/` holds the helper scripts the config calls (`install-webapp`, `launch-webapp.sh`,
  `spicetify-setup.sh`, `hyprpm-rebuild`). `linux-wallpaperengine` is not one of these — it's an AUR
  package (`linux-wallpaperengine-git`, installed via `run_onchange_after_06-gaming.sh.tmpl`), not a
  chezmoi-managed script.
- `dot_config/fish/functions/` is a large library of one-purpose media/document conversion functions
  (`pdf-*`, `vid2*`, `*2png`, …). Self-contained; add new ones as single files following the
  existing naming.

### Code style within the Lua config

`keybindings.lua` is the largest file and the clearest reference for all of the below; `rules.lua`
follows the same grouping/comment conventions at smaller scale.

- **Define helpers before their first use, top to bottom.** Every `local function` (or
  `local X = function(...) ... end` factory) appears above the `hl.bind()`/`hl.window_rule()` call
  that references it — never forward-referenced, never defined inline at the call site once the
  logic is more than a one-liner. `toggle_layout` (line 32) sits directly above the one bind that
  uses it; `smart_focus`/`try_focus`/`vertically_aligned` (§5 NAVIGATE) are built bottom-up, each
  depending only on helpers already defined earlier in the file.
- **No nested named functions.** A factory (`smart_focus`, `smart_move`, `toggle_app_special_workspace`,
  `bulk_move_windows`, `scrolloverview`, `reload`) returns an **anonymous** `function() ... end`
  closure — it never declares a second `local function` inside its own body. If a closure needs a
  sub-step, that step is its own top-level `local function` defined earlier, and the closure just
  calls it (e.g. `smart_focus` calls the top-level `try_focus`, it doesn't redefine it). This keeps
  every named function reachable and single-purpose instead of buried inside another one.
- **Formatting.** Tabs for indentation (not the 2-space stylua rule, which is nvim-tree-only — see
  §8). Spaces around `=` and `..`. A call that fits on one line stays on one line
  (`hl.bind(C.MODKEY .. "+Q", hl.dsp.window.close(), { description = "Kill active window" })`); once
  it doesn't, every argument to `hl.bind`/`hl.window_rule` drops to its own line, each on its own
  indent level, closing paren on its own line — never a half-wrapped call. If you touch a bind and
  notice it drifted from this (a stray 2-space indent, trailing whitespace, or `key=value` with no
  spaces — both have crept in before), fix it as part of the edit rather than matching the drift.
- **Semantic blocks, not chronological ones.** Top-level groups are numbered comment headers in
  ALL CAPS (`-- 1. WINDOW ACTIONS`, `-- 2. QUICK LAUNCHES`, ... through `-- 8. MULTIMEDIA`) that
  group binds by what they *do*, not by when they were added — a new bind goes into the matching
  numbered section, not appended at the end of the file. Within a section, related binds are
  clustered under a short lowercase comment (`-- Scrolling only`, `-- Cheathseet and session
  management`, `-- Wallpapers and colorscheme`), separated from the next cluster by a blank line.
- **Collapse repetition into a loop, don't hand-write it.** The ten workspace-number binds, the ten
  move-to-workspace binds and the ten bulk-move binds are each a single `for key = 0, 9 do ... end`
  producing the description only on the `key == 0` case (§8), not ten near-identical `hl.bind()` calls.
- **No hardcoded literals for values `constants.lua` already names.** Modkey, terminal/browser/file
  manager commands, special-workspace names, the games workspace: use `C.MODKEY`, `C.TERMINAL`,
  `C.SPECIAL_WORKSPACE.MUSIC`, etc. Add a constant there before introducing a second copy of a literal.

---

## 4. Hyprland Lua config

`hyprland.lua` is loaded **instead of** `hyprland.conf` when it exists — checked once at startup, not
merged. There is no `.conf` fallback anymore.

`require("lua.foo")` replaces `source =`, resolved relative to `~/.config/hypr/`. Module order in
`hyprland.lua` mirrors the old source chain. It is a template (`hyprland.lua.tmpl`) only to drop
`require("lua.gaming")` / `require("lua.plugins")` when `gaming` / `plugins` is `false` (both files are
always deployed).

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
| `plugins.lua` | plugin options, `hyprpm reload` at start, plugin binds (scrolloverview). `plugins = true` only |
| `gaming.lua` | latency/rendering tuning (tearing, direct scanout, VRR), the games window rule, competitive-games VRR, game mode + its binds. `gaming = true` only |
| `misc.lua` | the `misc` block |

Setters: `hl.config`, `hl.bind`, `hl.monitor`, `hl.workspace_rule`, `hl.window_rule`, `hl.layer_rule`,
`hl.curve`/`hl.animation`, `hl.device`, `hl.gesture`, `hl.env`, `hl.exec_cmd`, `hl.on`,
`hl.define_submap`, `hl.dispatch`, `hl.notification.create`, `hl.timer`.

Queries (all verified live): `hl.get_config(key)`, `hl.get_windows(filters)` — includes windows on
*hidden* special workspaces, which is what makes the special-workspace toggle work —
`hl.get_active_workspace()`, `hl.get_workspace_windows(id)`, `hl.get_active_window()`,
`hl.get_workspaces()`. An `HL.Window` exposes `class`, `title`, `initial_class`, `initial_title`,
`address`, `workspace`, `pid`.

---

## 5. Noctalia v5

**Invariant: Hyprland Lua ⟺ Noctalia v5; Hyprland `.conf` ⟺ Noctalia v4.** We use Lua + v5. Do not
mix. v4 (`noctalia-shell`, JSON at `~/.config/noctalia/`, run as `qs -c noctalia-shell`) is removed;
`paru -S noctalia-shell` brings it back. v5 is the `noctalia` binary, TOML at `~/.local/state/noctalia/`.

- IPC is `noctalia msg <command>`, and **`noctalia msg --help` is authoritative** — prefer it over
  the docs. `keybindings.lua` wraps it in a local `ipc()` helper.
- **v5 settings: only `settings.toml` is tracked**, at `dot_local/private_state/noctalia/settings.toml`
  (`private_` because `~/.local/state` is 0700). Everything else there — history, usage stats,
  downloaded caches, plugin build output — stays untracked via `.chezmoiignore`.
- **Plugin IDs are `<author>/<plugin>:<entry>`.** Panels: `panel-toggle noctalia/mpvpaper:picker`.
  Events: `plugin <author/plugin:entry> <target[:bar]> <event> [payload]`, target `all` for singleton
  services. Enumerate what's installed with `noctalia msg plugins list` — the v4 directory names
  under `~/.config/noctalia/plugins/` are **not** valid v5 IDs (no `:entry` half).
- **Not every plugin is a panel.** Kaomoji is a *launcher provider*, reached as
  `panel-toggle launcher "/kao"`. Bongo Cat has no panel at all. Providers use the
  `shell.launcher.provider_prefix` char: `/emo`, `/kao`, `/calc`, `/wall`, `/session`, `/win`.
- **Not every plugin has IPC.** W Engine has no handler, so its kill path is
  `pkill -f linux-wallpaperengine` alongside mpvpaper's real `clear-all` event.
- **A plugin's top-level Luau chunk gets 100 ms of CPU, its callbacks 25 ms** — hardcoded in
  Noctalia, no setting raises it. keybind-cheatsheet scans its config inside that chunk, and the
  default root `hyprland.lua` (15 modules, 48 KB) overruns it, leaving the panel spinning on
  "Reading keybindings..." forever with nothing in the log but a `'chunk' … CPU budget` error.
  `hyprland_lua_config` therefore points at `dot_config/hypr/cheatsheet.lua.tmpl`, which renders
  *only* the `-- N. SECTION` headers and literal `description = "..."` strings out of
  `keybindings.lua` (plus `gaming.lua` when `gaming = true`) — no `require`, so one file is read instead of fifteen. Bindings
  themselves come from `hyprctl binds -j`; the scan supplies categories only. Pointing the plugin
  straight at `lua/keybindings.lua` was tried and still overran.
- The generated file has no `..` on any line, so every rule registers as an *exact* match rather
  than the plugin's `..`-means-prefix guess. Keep it that way — prefix rules also make the 25 ms
  `hyprctl binds` callback slower, and it has overrun before.
- Screenshots use Noctalia native (`screenshot-region`,
  `screenshot-fullscreen [pick|monitor|all]`). There is **no per-window** mode — `pick` picks a
  monitor. `hyprshot` was removed, so per-window capture is gone.

### Webapps

`dot_local/bin/executable_install-webapp` creates chromium `--app=` desktop entries. Chromium derives
the Wayland app_id as `chrome-<host><path with / → _>-Default`. Confirmed live:
`chrome-gemini.google.com__app-Default`, `chrome-claude.ai__-Default` (an empty path still yields
`__`). Match these **prefix-anchored and per-host** — a blanket `^chrome-.*-Default$` would drag
WhatsApp, ddocs and MCHOSE HUB into whatever workspace you're scoping.

For terminal tools, `ghostty --class=<id> -e <cmd>` sets a deterministic app_id (ghostty exposes any
config key as a CLI flag), far more robust than matching volatile terminal titles. Verified live:
`ghostty --class=ai.claude` produces class `ai.claude`. The sysmon workspace (`SUPER+Delete` → btop)
uses this pattern — class `sysmon.btop`, matched in both `keybindings.lua` and `rules.lua` — because
ghostty's title updates only after the window maps, too late for an open-time workspace rule.

### Greeter (noctalia-greeter + greetd, replaces SDDM)

Login manager of choice is **greetd** running **noctalia-greeter**, not SDDM — see
`run_onchange_after_04-noctalia-greeter.sh.tmpl`. Both packages come from CachyOS's own repos
(`cachyos`/`cachyos-extra-v3`) via plain `pacman`, not the AUR, despite `noctalia-greeter`'s upstream
docs describing a from-source build. A fresh CachyOS install with Hyprland selected in Calamares
already ships `greetd`/`noctalia-greeter` by default (confirmed via the CachyOS `cachyos-hypr-noctalia`
rootfs-overlay repo), so there this script is a no-op.

**The script only adds — it never assumes or removes anything.** It installs the two packages
(`--needed`, safe to rerun) and points `/etc/greetd/config.toml` at `noctalia-greeter-session`, but
deliberately does **not** uninstall SDDM/`sddm-silent-theme`, disable whatever display manager is
currently enabled, or enable `greetd.service` itself — flipping the live login manager is exactly
the kind of thing that shouldn't happen silently on some future unattended `chezmoi apply`. Existing
dotfiles users migrating from SDDM (or Plasma's login, or anything else) get the packages/config
staged, then do the actual switch by hand:
```
sudo systemctl disable <current-display-manager>.service
sudo systemctl enable greetd.service
sudo reboot
```
SDDM is intentionally left alone as a fallback, not force-removed.

- The package's own `post_install`/`post_upgrade` scriptlet runs `setup_greeter_system.sh`
  automatically on every `pacman -S`/`-U` — it creates the `greeter` system user, chowns
  `/var/lib/noctalia-greeter/`, and seeds `greeter.toml`/`sync.toml` via
  `noctalia-greeter-apply-appearance --setup-system`. Never call that script manually.
- Two config files, both under `/var/lib/noctalia-greeter/` (root/`greeter`-owned, `0750`, not
  chezmoi-managed — machine-local state like `monitors.lua`, edited by hand):
  **`sync.toml`** is written by `noctalia msg greeter-sync` (polkit-escalated) and mirrors whatever
  the live Noctalia desktop is currently themed with — wallpaper, full color palette (works for
  `community`/`custom` palettes too, not just built-ins — confirmed with the `Heartbox` community
  palette), and `[output] scales`/`transforms`. It is **not** a live watcher — re-run `greeter-sync`
  by hand after any desktop theme change; nothing pushes it automatically.
  **`greeter.toml`** is declarative and never touched by sync/UI. The greeter script only adds
  `[appearance] hide_logo = true` to it, never overwrites it. This is where per-machine
  overrides go — most importantly `[output] name/width/height`, since `greeter-sync` does **not**
  carry the actual monitor mode (only scale/transform), so a greeter left on its default output
  config renders at 1080p regardless of the monitor's native resolution.
- `/etc/greetd/config.toml`'s `default_session.command` must point at
  `/usr/bin/noctalia-greeter-session`, not the stock `agreety` (greetd's bundled bare-tty fallback,
  pulled in as a hard dependency of the `greetd` package itself — harmless to leave installed, just
  not what boots by default once this is set).
- **KWallet auto-unlock is deliberately not configured for greetd** — no `pam_kwallet5.so` lines in
  `/etc/pam.d/greetd` (unlike the old `/etc/pam.d/sddm`), a conscious choice to keep the migration
  "vanilla" rather than re-adding the SDDM-era LUKS/autologin PAM patching. See "Setup facts" above.
- No autologin.
- LUKS is unrelated here: root is plain btrfs despite a non-empty `/etc/crypttab` (inactive entry).
  Decryption happens in the initramfs before any greeter runs.

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
   `hl.dsp.exec_cmd("hyprctl dispatch ...")` is dead on arrival (this silently broke every
   scrolloverview bind once).

6c. **Workspace window rules are evaluated on window *open* only.** A window moved out of its special
   workspace afterwards stays out. That's why the throw-in binds (`SUPER+SHIFT+<key>`) can park *any*
   app in a special workspace and have it stick. An app that closes to tray and reopens gets the
   rule applied afresh.

6d. **`hl.dsp.focus({ window = w })` reveals a hidden special workspace** as it focuses, and there is
   no `hl.dsp.window.focus` — focusing is always `hl.dsp.focus`.

6e. **`m[N]` is a *workspace* selector, not a monitor identifier.** A workspace rule's `monitor` field
   takes a monitor name or `desc:...`. Passing `m[1]` fails to resolve *silently*: the workspace loses
   its pin but keeps `persistent`, so it gets created on whatever monitor happens to exist.

6f. **A workspace rule's `monitor` cannot be un-set.** Re-issuing the rule with `monitor = ""` leaves
   the previous monitor in place — rules merge rather than replace for that field. `persistent` *does*
   update, and dropping it destroys the empty workspace. To "unpin", assign the monitor you do want;
   `monitors.lua` pins everything to the sole monitor when there's only one.

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

   `hyprctl eval` is **not** a keybind context, so a plugin call that works there can still be wrong
   in a bind. When mocking a plugin in the stubbed-`hl` harness, mirror both branches and `assert`
   that `hl.dispatch` is never handed `nil`.

6h. **`hl.dsp.exec_raw` is not a dispatcher runner** — it `spawnRaw`s a process (exec without a
   shell). For "re-apply my monitors" the dispatcher is `hl.dsp.force_renderer_reload()`; note
   `monitor` is a config *keyword*, never a dispatcher.

6i. **`change_id` (Hyprland 0.56) cannot target workspaces 1–10 here.** It rejects an occupied id, and
   `monitors.lua` makes 1–10 `persistent`, so all ten always exist. `SUPER+ALT+CTRL+<digit>` therefore
   moves each window individually; `change_id` is still right for *stashing* a layout at an unused
   high id.

6j. **`scrolling.column_width` stays at upstream's `0.5`** (`1.0` was tried and reverted).
   `K`/`J`/`SHIFT+K`/`SHIFT+J` do in-workspace focus/move first and fall back to workspace-scroll at
   the edge (`smart_focus`/`smart_move`). `fit_into_view`, `fit active` and `inhibit_scroll` are
   **layout messages**, not config options — use `hl.dsp.layout(...)`, not `hl.config`.

### Editor support for the `hl` global

Hyprland ships LuaLS stubs at `/usr/share/hypr/stubs/hl.meta.lua`, giving real field-level checking
of the `hl` global. They're wired up by a `.luarc.json` that exists twice on purpose:

- `dot_config/hypr/dot_luarc.json` → `~/.config/hypr/.luarc.json`, for editing the live config
- `dot_config/hypr/.luarc.json` → literal dotfile in the *source* tree (chezmoi ignores `.`-prefixed
  source entries), for editing the files here. Keep the two in sync.

It sits in `dot_config/hypr/`, not `lua/`, so `hyprland.lua` is covered. It's safe for nvim: lua_ls
treats `.luarc.json` as its top-priority root marker, and `dot_config/hypr/` isn't an ancestor of
`dot_config/nvim/`.

Verify by pointing the mason binary at the directory holding `.luarc.json` (aiming at `lua/` misses it):

```bash
~/.local/share/nvim/mason/bin/lua-language-server --check dot_config/hypr --checklevel=Warning
```

Expect "no problems found"; without the config it reports 335.

### Testing multi-monitor behaviour without extra hardware

`hyprctl output create headless <NAME>` adds a virtual monitor and `hyprctl output remove <NAME>`
takes it away. Both fire `monitor.layout_changed`, so real add/remove paths run, including the drop
back to one monitor. A headless output reports `physical_width/height = 0`, which also exercises
EDID-missing fallbacks. Use the stubbed-`hl` harness (§1) for geometry a headless output can't produce.

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

## 8. Conventions

> [!IMPORTANT]
> Avoid commenting obvious lines, this should be 80% of times, for that 20% where comments
> are needed **DO NOT BE VERBOSE**.
> No mechanism narration, no listing every file/case it touches. If a comment runs past 2 lines,
> cut it, don't wrap it. This applies to every file type in this repo: Lua, bash, TOML, everywhere.

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
- **No backward compatibility or migration code for renamed/removed paths.** When a directory, file or
  setting changes (e.g. `Work` → `Projects`), update the source only: no scripts that move user data,
  no compat symlinks. Existing users migrate their own files by hand.
- This file is `AGENTS.md`; `CLAUDE.md` is only a symlink to it. Keep it agent-neutral: never retitle it
  `CLAUDE.md` or add Claude-specific boilerplate (e.g. from `/init`).

---

## 9. Commands that must never be run

- **`pacman -Rdd <pkg>`** — skips *both* the dependency check and the conflict check. It exists to
  force-remove a package that something else still depends on, which leaves that something else
  installed but broken. Check first: `pacman -Qi <pkg> | grep 'Required By'`. `None` means a plain
  `-Rns` is enough and safe; anything listed there breaks the moment `-Rdd` succeeds instead.

- **`pacman -Sy` without an immediate `-u`** — refreshes the package database without upgrading
  installed packages. Arch (and CachyOS) explicitly do not support this: newer repo metadata against
  stale installed packages can resolve dependencies onto incompatible library versions system-wide.
  Always `pacman -Syu` together, never a bare `-Sy` left sitting before some other step runs against
  the now-refreshed database.
