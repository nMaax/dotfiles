-- WINDOW RULES
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

local C = require("lua.constants")

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
	match = { class = "^sysmon\\.btop$" }, -- C.SYSMON_CLASS, Hyprland-regex escaped
	workspace = "special:" .. C.SPECIAL_WORKSPACE.SYSMON,
})

-- Discord and Telegram get their own workspaces
hl.window_rule({
	name = "discord-workspace-class",
	match = { class = "^(discord|equibop|vesktop)$" }, -- keep in sync with keybindings.lua's SUPER+D matcher
	workspace = "special:" .. C.SPECIAL_WORKSPACE.DISCORD,
})
hl.window_rule({
	name = "telegram-workspace-class",
	match = { class = "^(org\\.telegram\\.desktop|TelegramDesktop)$" }, -- keep in sync with keybindings.lua's SUPER+T matcher
	workspace = "special:" .. C.SPECIAL_WORKSPACE.TELEGRAM,
})

-- Password managers workspace.
hl.window_rule({
	name = "password-workspace-class",
	match = {
		-- keep in sync with keybindings.lua's SUPER+P matcher
		class = "^(org\\.keepassxc\\.KeePassXC|keepassxc|KeePass2|[Bb]itwarden|1[Pp]assword|Enpass|proton-pass|org\\.kde\\.kwalletmanager5|org\\.gnome\\.Seahorse|org\\.gnome\\.World\\.Secrets)$",
	},
	workspace = "special:" .. C.SPECIAL_WORKSPACE.PASSWORD,
})

-- AI workspace
hl.window_rule({
	name = "ai-workspace-class",
	match = {
		-- keep in sync with keybindings.lua's SUPER+A matcher
		class = "^(chrome-(gemini\\.google\\.com|github\\.com__copilot|chatgpt\\.com|claude\\.ai).*|Claude)$",
	},
	workspace = "special:" .. C.SPECIAL_WORKSPACE.AI,
})

-- Music workspace
hl.window_rule({
	name = "music-workspace-class",
	match = { class = "^([Ss]potify|feishin|Supersonic|Cider|com\\.github\\.th_ch\\.youtube_music|Plexamp)$" }, -- keep in sync with keybindings.lua's SUPER+M matcher
	workspace = "special:" .. C.SPECIAL_WORKSPACE.MUSIC,
})
hl.window_rule({
	name = "music-workspace-title",
	match = { initial_title = "^Spotify( (Premium|Free))?$" },
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

-- Game Launchers Workspace
hl.window_rule({
	name = "games-launchers-workspace-class",
	match = { class = "^(steam|lutris|com\\.heroicgameslauncher\\.hgl|heroic)$" }, -- keep in sync with keybindings.lua's SUPER+G matcher
	workspace = "special:" .. C.SPECIAL_WORKSPACE.GAMES,
})

-- Games
hl.window_rule({
	name = "games-workspace",
	match = {
		class = "^(steam_app_.*|.*\\.exe|wine|Wine|lutris_.*|heroic_.*|love)$", -- love is VRRTest
	},
	workspace = C.GAMES_WORKSPACE,
	no_vrr = false, -- Always try to enable VRR
	idle_inhibit = "always", -- Do not sleep
	content = "game", -- Force it: many games never self-report via the content-type protocol,
	-- which is what drives the "auto" direct_scanout/vrr/no_break_fs_vrr settings in performance.lua
	confine_pointer = true, -- Keep the cursor on this monitor -- this is a multi-monitor rig
})
