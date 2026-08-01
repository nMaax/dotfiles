-- WINDOW RULES
-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more

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
	match = { class = "^sysmon\\.btop$" },
	workspace = "special:sysmon",
})

-- Discord and Telegram get their own workspaces
hl.window_rule({
	name = "discord-workspace-class",
	match = { class = "^(discord|equibop|vesktop)$" },
	workspace = "special:discord",
})
hl.window_rule({
	name = "telegram-workspace-class",
	match = { class = "^(org\\.telegram\\.desktop|TelegramDesktop)$" },
	workspace = "special:telegram",
})

-- Password managers workspace.
hl.window_rule({
	name = "password-workspace-class",
	match = {
		class = "^(org\\.keepassxc\\.KeePassXC|keepassxc|KeePass2|[Bb]itwarden|1[Pp]assword|Enpass|proton-pass|org\\.kde\\.kwalletmanager5|org\\.gnome\\.Seahorse|org\\.gnome\\.World\\.Secrets)$",
	},
	workspace = "special:password",
})

-- AI workspace
hl.window_rule({
	name = "ai-workspace-class",
	match = {
		class = "^chrome-(gemini\\.google\\.com|github\\.com__copilot|chatgpt\\.com|claude\\.ai).*$",
	},
	workspace = "special:ai",
})

-- Music workspace
hl.window_rule({
	name = "music-workspace-class",
	match = { class = "^([Ss]potify|feishin|Supersonic|Cider|com\\.github\\.th_ch\\.youtube_music|Plexamp)$" },
	workspace = "special:music",
})
hl.window_rule({
	name = "music-workspace-title",
	match = { initial_title = "^Spotify( (Premium|Free))?$" },
	workspace = "special:music",
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
	match = { class = "^(steam|lutris|com\\.heroicgameslauncher\\.hgl|heroic)$" },
	workspace = "special:games",
})

-- Games
hl.window_rule({
	name = "games-workspace",
	match = {
		class = "^(steam_app_.*|.*\\.exe|wine|Wine|lutris_.*|heroic_.*|love)$", -- love is VRRTest
	},
	workspace = "11", -- GAMES_WORKSPACE (see monitors.lua)
	no_vrr = false, -- Always try to enable VRR
	idle_inhibit = "always", -- Do not sleep
	content = "game", -- Force it: many games never self-report via the content-type protocol,
	-- which is what drives the "auto" direct_scanout/vrr/no_break_fs_vrr settings in performance.lua
	confine_pointer = true, -- Keep the cursor on this monitor -- this is a multi-monitor rig
})
