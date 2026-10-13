-- WINDOW RULES
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

local C = require("lua.constants")
local special = require("lua.special")

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

-- Don't let the screen sleep while anything is fullscreen (video, calls, games)
hl.window_rule({
	name = "idle-inhibit-fullscreen",
	match = { class = ".*", fullscreen = true },
	idle_inhibit = "fullscreen",
})

-- Float small utility apps
hl.window_rule({
	name = "float-transient-utilities",
	-- confirmed live: pavucontrol's real class is org.pulseaudio.pavucontrol, not "pavucontrol"
	match = { class = "^(org\\.pulseaudio\\.pavucontrol|nm-connection-editor|blueman-manager|file-roller)$" },
	float = true,
})

-- Center and remember the size of any floating window, as a baseline for the
-- more specific float rules below
hl.window_rule({
	name = "float-center-persistent-size",
	match = { float = true },
	center = true,
	persistent_size = true,
})

-- Float common file/auth dialogs regardless of which app spawns them
local modalMatches = {
	{ title = "^(Open|Save As|Authentication Required|Choose Files|File Upload|Confirm to replace files)(.*)$" },
	{ class = "^([Xx]dg-desktop-portal-gtk)$" },
	{ class = "^(.*[Dd]ialog.*)$" },
	{ title = "^(.*[Dd]ialog.*)$" },
}
for i, m in ipairs(modalMatches) do
	hl.window_rule({ name = "float-common-modal-" .. i, match = m, float = true })
end

-- Picture-in-Picture: small, pinned, corner-sized float
hl.window_rule({
	name = "picture-in-picture",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	keep_aspect_ratio = true,
	size = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
	pin = true,
})

-- NOCTALIA RULES
-- See https://docs.noctalia.dev/v5/compositor-settings/hyprland/

-- Noctalia windows float
hl.window_rule({
	name = "noctalia-settings",
	match = { class = "^dev\\.noctalia\\.Noctalia$" },
	float = true,
	size = { 1080, 920 },
})

-- Blur Noctalia's own surfaces (bar, panels, dock, osd, window switcher, etc.)
hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

--- CUSTOM WORKSPACES

-- System Monitor workspace
hl.window_rule({
	name = "sysmon-workspace-class",
	match = { class = special.regex(C.APP_CLASSES.SYSMON) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.SYSMON,
})

-- Discord and Telegram get their own workspaces
hl.window_rule({
	name = "discord-workspace-class",
	match = { class = special.regex(C.APP_CLASSES.DISCORD) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.DISCORD,
})
hl.window_rule({
	name = "telegram-workspace-class",
	match = { class = special.regex(C.APP_CLASSES.TELEGRAM) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.TELEGRAM,
})

-- Password managers workspace.
hl.window_rule({
	name = "password-workspace-class",
	match = { class = special.regex(C.APP_CLASSES.PASSWORD) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.PASSWORD,
})

-- AI workspace
hl.window_rule({
	name = "ai-workspace-class",
	match = { class = special.regex(C.APP_CLASSES.AI) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.AI,
})

-- Music workspace
hl.window_rule({
	name = "music-workspace-class",
	match = { class = special.regex(C.APP_CLASSES.MUSIC) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.MUSIC,
})
hl.window_rule({
	name = "music-workspace-title",
	match = { initial_title = special.regex(C.MUSIC_TITLES) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.MUSIC,
})

-- Small utilities (only calculator for now)
hl.window_rule({
	name = "gnome-calculator",
	match = { class = "^(org\\.gnome\\.Calculator)$" },

	-- Small, floating, and pinned regardless of the workspace
	float = true,
	size = "400 600",
	center = true,
	pin = true,
})
