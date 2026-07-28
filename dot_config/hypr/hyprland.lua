-- Hyprland Lua config entry point.
--
-- Hyprland loads this file INSTEAD of hyprland.conf whenever it exists (checked
-- once at startup, not a merge). The legacy hyprland.conf and hyprland/*.conf
-- files are therefore inert; they're kept only as a rollback path, and
-- ~/.local/bin/hyprland-conf-cleanup.sh removes them when that's no longer
-- wanted.
--
-- Module order below mirrors the old `source =` chain. `require` replaces
-- `source`, resolved relative to ~/.config/hypr/.
--
-- Colors are NOT required here: noctalia regenerates lua/colors.lua from
-- lua/colors-template.lua via its own user-templates.toml mechanism, and
-- lua/lookandfeel.lua requires that generated file directly. See
-- dot_config/noctalia/user-templates.toml.

require("lua.autostart")
require("lua.env")
require("lua.permissions") -- all commented out, nothing active (see file)
require("lua.monitors")
require("lua.lookandfeel")
require("lua.input")
require("lua.keybindings")
require("lua.rules")
require("lua.plugins")
require("lua.performance")
require("lua.misc")
