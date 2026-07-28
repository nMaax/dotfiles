-- INPUT
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- DEFAULT
hl.config({
	input = {
		-- TODO: maybe with lua I can make some of the following be conditional on which peripheral are plugged?
		-- e.g.
		--  - Disable all that stuff when not focused on a game, or when game-performance mode is not enabled
		--  - Use it as default on laptop, and us as default on desktop
		kb_layout = "us, it",
		kb_options = "compose:caps, grp:win_space_toggle",
		follow_mouse = 1,

		-- Keep keybinds POSITIONAL across the us/it layout toggle.
		--
		-- false (Hyprland's default, but pinned here explicitly): each bind's
		-- keysym is mapped to a keycode using the FIRST layout above (us), and
		-- matching is then done on keycodes -- so every bind fires on the same
		-- physical key no matter which layout is currently active. This is why
		-- keybindings.lua can be written entirely in us keysyms.
		--
		-- Setting this to true would make binds follow the ACTIVE layout instead,
		-- which would silently relocate every punctuation bind the moment
		-- SUPER+Space switches to it: "-" would jump from the us Minus key to the
		-- us "/" key, "/" (the cheatsheet) would stop working altogether, etc.
		-- Left explicit rather than implicit so an upstream default change can't
		-- quietly break all of them.
		resolve_binds_by_sym = false,

		sensitivity = 0.2,
		accel_profile = "adaptive",

		-- This one cannot be set per-device, enable just in case
		-- TODO: maybe with lua you can make it conditional when a game runs.
		-- force_no_accel = true,

		-- Scroll lock on middle button
		scroll_method = "on_button_down",
		scroll_button_lock = true,
		scroll_button = 274,

		touchpad = {
			natural_scroll = true,
			-- NOTE: Lua schema uses underscores (unlike hyprlang's hyphenated
			-- "tap-to-click") -- confirmed via hyprctl configerrors: "unknown
			-- config key 'input.touchpad.tap-to-click'".
			tap_to_click = true,
			disable_while_typing = true,
		},
	},
})

-- Per-device settings
-- See https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs for more

-- GAMING MOUSE
hl.device({
	name = "realtek-mchose-l7-pro+",
	sensitivity = 0,
	accel_profile = "flat",
	scroll_method = "no_scroll",
})

-- TOUCHPAD
hl.device({
	name = "elan050a:01-04f3:3158-touchpad",
	sensitivity = 0.8,
	accel_profile = "adaptive", -- Adaptive enables acceleration
})

-- GESTURES
-- See https://wiki.hypr.land/Configuring/Gestures

-- 3 fingers horizontal: Switch workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 3 fingers up: Toggle Fullscreen
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })

-- 3 fingers down: Toggle special workspace
hl.gesture({ fingers = 3, direction = "down", action = "special" })

-- 3 fingers pinch: Toggle floating
hl.gesture({ fingers = 3, direction = "pinch", action = "float" })

-- 3 fingers pinch + SUPER: Resize window
hl.gesture({ fingers = 3, direction = "pinch", mods = "SUPER", action = "resize" })
