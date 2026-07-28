-- LOOK AND FEEL
-- Refer to https://wiki.hypr.land/Configuring/Variables/
--
-- NOTE: Do not put performance-related settings here, they belong in performance.lua

-- NOTE (placeholder -- see migration plan, "Critical cross-cutting issue:
-- noctalia color variables"): these are the values currently resolved from
-- ~/.config/hypr/noctalia/noctalia-colors.conf ($primary/$tertiary/$surface/
-- $surface_lowest), inlined as static strings because that file is hyprlang
-- (not Lua) and out of scope to modify -- it's managed by the noctalia
-- package. They WILL go stale when noctalia switches color schemes, until a
-- live-read bridge is confirmed possible (needs io.open availability in this
-- Lua sandbox -- verify post-cutover, only testable via hyprctl eval once
-- this config is already active).
--
-- NOTE: gradients need the { colors = {...}, angle = N } table shape (not a
-- flat "colorA colorB Ndeg" string like hyprlang) -- confirmed against the
-- official shipped example config at /usr/share/hypr/hyprland.lua.

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,

        -- See https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
        col = {
            active_border = { colors = { "rgb(b9391f)", "rgb(5c575a)" }, angle = 90 }, -- $primary $tertiary 90deg
            inactive_border = { colors = { "rgb(000000)", "rgb(010101)" }, angle = 90 }, -- $surface $surface_lowest 90deg
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        layout = "scrolling", -- You can also switch to dwindle
    },

    dwindle = {
        preserve_split = true, -- You probably want this
    },

    scrolling = {
        -- None to do, I like the default :)
    },

    master = {
        new_status = "master",
    },

    cursor = {
        enable_hyprcursor = true,
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true, -- yes, please :)
    },
})

-- https://wiki.hypr.land/Configuring/Animations/
hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } }) -- A cleaner version of MD3 without the bounce
hl.curve("snappy", { type = "bezier", points = { { 0.3, 1 }, { 0, 1 } } }) -- High velocity start, instant lock-in
hl.curve("fastOut", { type = "bezier", points = { { 0.3, 0 }, { 1, 1 } } }) -- Starts slow, then vanishes instantly
hl.curve("fluid", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } }) -- A cleaner version of MD3 without the bounce

-- Windows
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "snappy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "fastOut", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "snappy" })

-- Layers
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "fluid", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "fastOut", style = "slide" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 4, bezier = "standard" })

-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "snappy", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4, bezier = "snappy", style = "slidefade left 40%" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 4, bezier = "snappy", style = "slidefade right 40%" })

-- Aesthetics
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "standard" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "standard" })
