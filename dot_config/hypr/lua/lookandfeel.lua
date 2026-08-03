-- LOOK AND FEEL
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

-- NOTE: Do not put performance-related settings here, they belong in performance.lua

local colors = require("lua.colors")
local C = require("lua.constants")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,

        -- See https://wiki.hypr.land/Configuring/Basics/Variables#variable-types
        col = {
            active_border = { colors = { colors.primary, colors.secondary, colors.tertiary }, angle = 45 },
            inactive_border = { colors = { colors.surface, colors.surface_lowest }, angle = 90 },
        },

        resize_on_border = true,

        layout = "scrolling", -- You can also switch to dwindle
    },

    binds = {
        -- pressing the current workspace's key returns to the previous one
        workspace_back_and_forth = true,
    },

    group = {
        col = {
            border_active = colors.secondary,
            border_inactive = colors.surface,
            border_locked_active = colors.error,
            border_locked_inactive = colors.surface,
        },
        groupbar = {
            disable_when_only = true,

            col = {
                active = colors.secondary,
                inactive = colors.surface,
                locked_active = colors.error,
                locked_inactive = colors.surface,
            },
        },
    },

    dwindle = {
        preserve_split = true, -- You probably want this
    },

    scrolling = {
        column_width = 0.5,
    },

    master = {
        new_status = "master",
    },

    cursor = {
        enable_hyprcursor = true,
        hide_on_key_press = true,
        inactive_timeout = 5,
        persistent_warps = true,
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
            color = "rgba(" .. C.SHADOW_HEX .. "ee)",
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

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } }) -- A cleaner version of MD3 without the bounce
hl.curve("snappy", { type = "bezier", points = { { 0.3, 1 }, { 0, 1 } } }) -- High velocity start, instant lock-in
hl.curve("fastOut", { type = "bezier", points = { { 0.3, 0 }, { 1, 1 } } }) -- Starts slow, then vanishes instantly
hl.curve("fluid", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } }) -- A cleaner version of MD3 without the bounce
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } }) -- Constant velocity, for the looping borderangle

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
