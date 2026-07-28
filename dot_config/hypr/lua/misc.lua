-- MISC
-- https://wiki.hypr.land/Configuring/Variables/#misc
--
-- NOTE: this sets a subset of `misc` keys; performance.lua sets `vrr` on the
-- same `misc` table in a separate hl.config() call. hyprlang additively
-- merges repeated top-level blocks across sourced files rather than
-- overwriting, and hl.config() is assumed to behave the same way (each call
-- sets only the keys it specifies) -- kept as two separate calls, mirroring
-- the original two-file split, rather than force-merging into one.
hl.config({
    misc = {
        focus_on_activate = false, -- whether Hyprland should focus an app that requests to be focused
        force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})
