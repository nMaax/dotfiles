-- Hyprland Lua config entry point.
-- Draft 1:1 translation of hyprland.conf's `source =` chain -- see the
-- "hyprland-lua-migration" plan for full context, the researched hl.* API
-- surface, and every flagged unknown referenced below.
--
-- NOT applied yet: this file is excluded via .chezmoiignore until it has
-- been tested live and the user is ready to restart Hyprland.
--
-- NOTE: noctalia-colors.conf (sourced first in the legacy config) is NOT
-- required here -- it's a hyprlang $var file, not Lua, and out of scope to
-- touch (managed by the noctalia package). Its currently-resolved values are
-- inlined as a static placeholder directly in lua/lookandfeel.lua.
--
-- NOTE (known unknown #1): multi-file `require` support in Hyprland's Lua
-- sandbox is UNVERIFIED -- `hyprctl eval`/`repl` only work once a Lua config
-- is already active, so this can't be pre-tested before the first real
-- cutover restart. If `require` errors at load time, flatten these into a
-- single hyprland.lua with section comment banners instead.

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
