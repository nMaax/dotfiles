-- INPUT
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- Default
hl.config({
	input = {
		kb_layout = "us, it",
		kb_options = "compose:caps, grp:win_space_toggle",
		resolve_binds_by_sym = false,
		follow_mouse = 1,

		sensitivity = 0.2,
		accel_profile = "adaptive",

		scroll_method = "on_button_down",
		scroll_button_lock = true,
		scroll_button = 274,

		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
			disable_while_typing = true,
		},
	},
})

-- PER-DEVICE INPUT CONFIGS
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#per-device-input-config

-- Gaming mouse
hl.device({
	name = "realtek-mchose-l7-pro+",
	sensitivity = 0,
	accel_profile = "flat",
	scroll_method = "no_scroll",
})

-- Touchpad
hl.device({
	name = "elan050a:01-04f3:3158-touchpad",
	sensitivity = 0.8,
})

-- GESTURES
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#gestures

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
