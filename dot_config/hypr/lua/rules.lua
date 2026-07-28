-- WINDOWS
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

-- System Monitor workspace
hl.window_rule({
	name = "sysmon-workspace-title",
	match = { title = "^(btop|nvtop|htop|top)$" },
	workspace = "special:sysmon",
})

-- Communication workspace
hl.window_rule({
	name = "comms-workspace-class",
	match = { class = "^(discord|equibop|vesktop|org.telegram.desktop|whatsapp|Element)$" },
	workspace = "special:communication",
})

-- Password managers workspace
hl.window_rule({
	name = "password-workspace-class",
	match = { class = "^(org.keepassxc.KeePassXC)" },
	workspace = "special:password",
})

-- AI workspace (replaces the old EasyEffects/audio workspace).
-- Two groups here: the CLI tools, which get an explicit `ghostty --class=` when
-- launched from keybindings.lua, and the chromium `--app=` webapps, whose app_id
-- chromium derives from the URL as chrome-<host><path, / -> _>-Default.
-- Deliberately scoped per-host rather than a blanket chrome-.* so the non-AI
-- webapps (WhatsApp, ddocs, MCHOSE HUB) are not caught.
-- NOTE: this is a Hyprland regex, not a Lua pattern -- hence \\. not %.
hl.window_rule({
	name = "ai-workspace-class",
	match = {
		class = "^(ai\\.claude|ai\\.antigravity|chrome-(gemini\\.google\\.com|github\\.com__copilot|chatgpt\\.com|claude\\.ai).*)$",
	},
	workspace = "special:ai",
})

-- Music workspace
hl.window_rule({
	name = "music-workspace-class",
	match = { class = "^([Ss]potify|feishin|Supersonic|Cider|com.github.th_ch.youtube_music|Plexamp)$" },
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
	-- Matches Steam, Lutris, and Heroic (com.heroicgameslauncher.hgl)
	match = { class = "^(steam|lutris|com.heroicgameslauncher.hgl|heroic)$" },
	workspace = "special:games",
})

-- Games get their own reserved workspace (11), so they never land in the middle
-- of the 1-10 rotation. 11 is outside that range on purpose: nothing existing is
-- sacrificed, and it is reachable via SUPER+SHIFT+G. Its gaps/border are zeroed
-- by the workspace_rule in monitors.lua.
--
-- NOTE: this replaces the previous `workspace = "unset"` (games stayed wherever
-- they happened to open).
hl.window_rule({
	name = "games-workspace",
	match = {
		content = "game",
		class = "^(steam_app_.*|.*\\.exe|wine|Wine|lutris_.*|heroic_.*|love)$", -- love is VRRTest
	},
	workspace = "11",
	no_vrr = false, -- Always try to enable VRR
	idle_inhibit = "always", -- Do not sleep
})

-- Noctalia settings window
-- See https://docs.noctalia.dev/v5/compositor-settings/hyprland/
hl.window_rule({
	name = "noctalia-settings",
	match = { class = "dev.noctalia.Noctalia" },
	float = true,
	size = { 1080, 920 },
})

-- Remove effects
hl.window_rule({
	name = "no-effect-overwatch",
	match = { title = "^(Overwatch)$" },

	-- Disable effects
	no_anim = true,
	no_blur = true,
	no_shadow = true,
	no_dim = true,
	rounding = 0,
	border_size = 0,
	decorate = false,
})

-- Blur Noctalia's own surfaces (bar, panels, dock, osd, window switcher, etc.)
-- See https://docs.noctalia.dev/v5/compositor-settings/hyprland/
-- TODO: part of the v5 upgrade, verify namespace pattern once noctalia v5 is
-- actually installed and running.
hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
