require("lua.autostart")
require("lua.env")
require("lua.permissions")
require("lua.monitors")

require("noctalia").apply_theme()

require("lua.lookandfeel")
require("lua.input")
require("lua.keybindings")
require("lua.rules")
require("lua.plugins")
require("lua.performance")
require("lua.misc")

-- TODO: we should move many function in dedicated files and re-organize the code overall
-- TODO: also constants should be moved, ideally here, and we should find some around (e.g. Dolphin is replaced by FileManager, Ghostty is replaced by Terminal etc.)
-- TODO: update all links to hyprland documentation
-- TODO: ask for finding QoL features online
-- TODO: fix various colorings from noctalia, also for community themes (e.g. Ghostty, FastFetch, heroic etc.)
-- TODO: make claude fix direct scanout on games, my suspicioun are, in order:
--    - the problem may be wallpaper engine
--    - the problem may be combination with vrr
--    - the problem may be using scrolling mode instead of dwindle
-- TODO: make claude find the best prefix for game launching in steam for cachyos
-- TOOD: make cluade optimize for battery and resources consumption
