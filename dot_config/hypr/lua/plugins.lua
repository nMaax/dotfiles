-- PLUGINS
-- See https://wiki.hypr.land/Plugins/Using-Plugins/
--
-- NOTE: plugin *loading* stays external via hyprpm (see the `hyprpm reload`
-- exec-once in autostart.lua) -- this repo never loaded the plugin via a
-- `plugin =` directive, only configured its options here. Whether
-- plugin-contributed option tables nest under hl.config({ plugin = {...} })
-- the same way core options do is unconfirmed (plugins register their own
-- config schema dynamically) -- verify at first live test.

hl.config({
    plugin = {
        scrolloverview = {
            gesture_distance = 300, -- how far is the "max" for the gesture
            scale = 0.7, -- preferred overview scale
            workspace_gap = 100,
            layout = "vertical", -- vertical or horizontal
            wallpaper = 0, -- 0: global only, 1: per-workspace only, 2: both
            blur = true, -- blur only the main overview wallpaper
            shadow = {
                enabled = true,
                range = 50,
                render_power = 3,
                color = "rgba(1a1a1aee)",
            },
        },
    },
})
