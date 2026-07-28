-- PLUGINS
-- See https://wiki.hypr.land/Plugins/Using-Plugins/
--
-- NOTE: plugin *loading* stays external via hyprpm (see the `hyprpm reload`
-- exec-once in autostart.lua) -- this repo never loaded the plugin via a
-- `plugin =` directive, only configured its options here.
--
-- BUGFIX: the `hl.config({ plugin = { scrolloverview = {...} } })` table
-- shape is correct (confirmed against the plugin's own README), but
-- `shadow.color` must be an integer (or gradient), NOT the hyprlang-only
-- `rgba(...)` string -- per the plugin's own docs: "The Hyprlang-only
-- rgba(...) syntax is not accepted there." Passing a string for that one
-- nested value made Hyprland reject the ENTIRE scrolloverview table as
-- malformed, which is why every sibling key (workspace_gap, layout, etc.)
-- was also showing as "unknown config key" in `hyprctl configerrors` --
-- not because the table shape itself was wrong.
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
                color = 0xee1a1a1a, -- rgba(1a1a1aee) as an AARRGGBB integer
            },
        },
    },
})
