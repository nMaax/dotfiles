-- Noctalia user-template source (see ~/.config/noctalia/user-templates.toml).
-- Rendered by noctalia into lua/colors.lua whenever the theme/
-- wallpaper changes, then `hyprctl reload` (the template's post_hook) picks
-- it up live -- same pattern as the existing nvim-base16 template.
--
-- NOTE: `surface_lowest` role name is a guess (Material You tonal naming
-- convention: surface_container_lowest) -- the original hyprlang export used
-- the abbreviated name "$surface_lowest"; verify this renders correctly
-- after the first template regeneration (a literal unrendered
-- "{{colors...}}" string in colors.lua means the role name is wrong).
return {
    primary = "rgb({{colors.primary.default.hex_stripped}})",
    secondary = "rgb({{colors.secondary.default.hex_stripped}})",
    tertiary = "rgb({{colors.tertiary.default.hex_stripped}})",
    surface = "rgb({{colors.surface.default.hex_stripped}})",
    surface_lowest = "rgb({{colors.surface_container_lowest.default.hex_stripped}})",
    error = "rgb({{colors.error.default.hex_stripped}})",
}
