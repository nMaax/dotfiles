-- LOOK AND FEEL
-- Refer to https://wiki.hypr.land/Configuring/Variables/
--
-- NOTE: Do not put performance-related settings here, they belong in performance.lua

-- Colors come from noctalia via its own documented templating mechanism
-- (~/.config/noctalia/user-templates.toml -> lua/colors-template.lua
-- -> lua/colors.lua, regenerated automatically on every theme/
-- wallpaper change, with `hyprctl reload` as the post_hook) -- same pattern
-- already used for the existing nvim-base16 colorscheme. This replaces the
-- earlier hardcoded-snapshot approach, which never updated on theme change.
local colors = require("lua.colors")

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
            active_border = { colors = { colors.primary, colors.secondary, colors.tertiary }, angle = 45 },
            inactive_border = { colors = { colors.surface, colors.surface_lowest }, angle = 90 },
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        layout = "scrolling", -- You can also switch to dwindle
    },

    -- NOTE (bugfix): this group{} block was dropped entirely in the original
    -- translation -- noctalia-colors.conf sets it via hyprlang `source`
    -- merge, but our Lua config never required/reproduced it, so grouped
    -- (tabbed) window borders were silently falling back to Hyprland
    -- defaults instead of noctalia's palette. Re-added here from the same
    -- live colors table used above.
    group = {
        col = {
            border_active = colors.secondary,
            border_inactive = colors.surface,
            border_locked_active = colors.error,
            border_locked_inactive = colors.surface,
        },
        groupbar = {
            -- Hide the tab strip when a group holds only one window -- there is
            -- nothing to switch between, so it is pure visual noise. (New in
            -- Hyprland 0.56.)
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
        -- Niri-like behaviour: a new window takes the FULL screen width and the
        -- tape scrolls horizontally, instead of splitting the screen 50/50 with
        -- the previous window. The stock default is 0.5, which is exactly what
        -- caused the half-screen split.
        --
        -- Note this is the *default* width only -- colresize and `fit active`
        -- (SUPER+SHIFT+X) still resize columns freely afterwards, and
        -- scrolling:explicit_column_widths (0.333/0.5/0.667/1.0) remains the
        -- preset list for colresize +conf/-conf.
        column_width = 1.0,
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
hl.animation({ leaf = "borderangle", enabled = true, speed = 1.4, bezier = "default", style = "loop" })
