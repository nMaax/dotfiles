-- GAMING
-- Always deployed, but only required with gaming = true in chezmoi.toml (hyprland.lua.tmpl).

local C = require("lua.constants")
local toggle_app_special_workspace = require("lua.special").toggle_app_special_workspace

local function ipc(args)
	return "noctalia msg " .. args
end

-- PERFORMANCE
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/#vrr

-- NOTE: Tearing v. VRR
--
--   Tearing (experimental): GPU goes as fast as possible, the monitor grabs the most recent frame.
--     You should idealy set unlimited framerete in your games to benefit from this.
--
--   VRR: The monitor will wait for the GPU to finish rendering a frame,
--     and will display it when ready. This is better for a smooth experience (smoother frametime curve),
--     while introducing minimal input lag in games (~1ms --- according to Optimum, in a video of 4y ago!).
--     You should idealy set a framerate limit in your games to match your monitor's refresh rate,
--     e.g. minus 3~4 FPS w.r.t. refresh rate.
--
--   ==> taxonomy: GSync is a type of Adaptive Sync, FreeSync is a type of Adaptive Sync.
--                 Adaptive Sync is a type of VRR (Variable Refresh Rate)
--                 The above always holds, however, generally speaking we refer to all 4 as the
--                 same concept.
--
--                 V-Sync is the old way to fix tearing, which introduced much latency
--                 and is now mostly replaced by VRR. TURN IT OFF!
--
--   Generally, I recomend VRR over tearing, as the input latency is negligible and it provides the massive
--   improvement of a smoother frametime curve.
--
--   BUT on OLED/VA panels VRR flickers dark scenes whenever FPS fluctuates (the refresh rate follows it).
--   So games default to VRR off (fixed refresh, still no tearing), see below; SUPER+ALT+V toggles it.

hl.config({
	general = {
		-- Master switch to allow screen tearing.
		-- This only enables the capability of tearing. Windows will NOT tear unless:
		--   - they in fullscreen
		--   - are the only visible element on screen (no notifications, no bars, no volume control)
		--   - have an 'immediate = yes' windowrule (rules.lua) dedicated to them
		allow_tearing = false,
	},

	cursor = {
		-- Keep hardware cursors ON (required for direct scanout). Hardware cursors make the GPU generate a
		-- second layer dedicated to the cursor, which theoretically reduces latency, as the software doesn't
		-- have to artificially remove pixels where the cursor is sitting -- however, in practice this creates
		-- issues with tearing (due to experimentality of such feature)
		-- 0 - use hw cursors if possible, 1 - don't use hw cursors, 2 - auto (disable when tearing)
		no_hardware_cursors = 0,

		-- Makes hardware cursors use a CPU buffer. Required on Nvidia to have HW cursors.
		-- 0 - off, 1 - on, 2 - auto (nvidia only)
		use_cpu_buffer = 2,

		-- Disables scheduling new frames on cursor movement for fullscreen apps with VRR enabled
		-- to avoid framerate spikes (may require no_hardware_cursors = true)
		-- 0 - off, 1 - on, 2 - auto (on with content type 'game')
		no_break_fs_vrr = 2,
	},

	render = {
		-- Direct scanout attempts to reduce lag when there is only one fullscreen
		-- application on a screen (e.g. game).
		-- This only works if hardware cursor is enabled (no_hardware_cursors = 0)
		-- It is also recommended to set this to false if the fullscreen application shows
		-- graphical glitches --- A known issue consists in games on native Wayland presenting a
		-- black screen (e.g Overwatch) when direct_scanout is enabled. In such cases use
		-- XWayland (don't set PROTON_ENABLE_WAYLAND=1), among the two (losing Wayland native v. losing
		-- direct_scanout) losing direct_scanout is much worse. Overwatch on XWayland + direct scanout works.
		-- 0 - off, 1 - on, 2 - auto (on with content type 'game')
		direct_scanout = 2,
	},

	misc = {
		-- Controls the VRR (Adaptive Sync) of your monitors.
		-- Video/games only; gaming monitors set the same in monitors.lua. Games default to no_vrr
		-- (below) because of OLED VRR flicker, toggle it per game with SUPER+ALT+V.
		-- 0 - off, 1 - on, 2 - fullscreen only, 3 - fullscreen with video or game content type
		vrr = 3,
	},
})

-- GAME RULES
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Games
hl.window_rule({
	name = "games-workspace",
	match = {
		class = "^(steam_app_.*|.*\\.exe|wine|Wine|lutris_.*|heroic_.*|love|[Mm]inecraft(\\\\*.*| .*)?|net\\.minecraft\\.client\\.main\\.Main)$", -- love is VRRTest
	},
	workspace = C.GAMES_WORKSPACE,
	-- VRR off by default: fluctuating FPS swings the refresh rate, which flickers dark scenes on OLED.
	-- Fixed 240Hz, no tearing. SUPER+ALT+V re-enables it per game (best with a steady FPS cap).
	no_vrr = true,
	idle_inhibit = "always", -- Do not sleep
	content = "game", -- Force it: many games never self-report via the content-type protocol,
	-- which is what drives the "auto" direct_scanout/vrr/no_break_fs_vrr settings above, and game mode
	confine_pointer = true, -- Keep the cursor on this monitor -- this is a multi-monitor rig
})

-- Competitive games: VRR on by default (cap FPS in-game below what the GPU always holds).
-- Done via set_prop, not a window rule: a second rule can't reliably override no_vrr = true above.
local COMPETITIVE_GAMES = {
	steam_app_2357570 = true, -- Overwatch
}
hl.on("window.open", function(window)
	if COMPETITIVE_GAMES[window.class] then
		hl.dispatch(hl.dsp.window.set_prop({ prop = "no_vrr", value = "false", window = window }))
	end
end)

-- 9. GAMING
-- Game mode (mutes OSD and notifications, switches to dwindle to prevent focus/pointer loss in games).
-- Any layer surface mapping (toast, OSD, launcher) makes a hidden *scrolling* workspace drop the
-- game's pointer lock: https://github.com/hyprwm/Hyprland/issues/16326, so no scrolling while gaming.
-- Turns on by itself when a game window (content type "game", see rules.lua) opens, and off when the
-- last one closes -- unless it was already on (e.g. toggled by hand), then it's left alone.
local function dnd_on()
	local handle = io.popen(ipc("notification-dnd-status"))
	local status = handle and handle:read("*l")
	if handle then
		handle:close()
	end
	return status == "on"
end

local game_mode_auto = false -- whether game mode was turned on by a game opening
local layout_before_game_mode

local function set_game_mode(on)
	if on then
		io.popen(ipc("osd-disable")):close()
		io.popen(ipc("notification-dnd-set true")):close()
		layout_before_game_mode = hl.get_config("general.layout")
		hl.config({ general = { layout = "dwindle" } })
		hl.notification.create({ text = "🎮 Game Mode: ON (OSD & Notifications disabled, dwindle)", timeout = 2500 })
	else
		io.popen(ipc("osd-enable")):close()
		io.popen(ipc("notification-dnd-set false")):close()
		if layout_before_game_mode then -- nil after a reload, which already restored the configured layout
			hl.config({ general = { layout = layout_before_game_mode } })
		end
		hl.notification.create({ text = "🎮 Game Mode: OFF (OSD & Notifications enabled)", timeout = 2500 })
	end
end

local function toggle_game_mode()
	game_mode_auto = false
	set_game_mode(not dnd_on())
end

local function game_running(except)
	for _, window in ipairs(hl.get_windows()) do
		if window.content_type == "game" and window.address ~= except then
			return true
		end
	end
	return false
end

hl.on("window.open", function(window)
	if window.content_type == "game" and not dnd_on() then
		game_mode_auto = true
		set_game_mode(true)
	end
end)

hl.on("window.close", function(window)
	if game_mode_auto and window.content_type == "game" and not game_running(window.address) then
		game_mode_auto = false
		set_game_mode(false)
	end
end)

-- A config reload resets the layout to scrolling: put dwindle back if a game is still running
if game_running() and dnd_on() then
	game_mode_auto = true
	hl.config({ general = { layout = "dwindle" } })
end

hl.bind(
	C.MODKEY .. "+ALT+Z",
	toggle_game_mode,
	{ description = "Toggle game mode (mute OSD & notifications, dwindle layout)" }
)
hl.bind(
	C.MODKEY .. "+ALT+V",
	hl.dsp.window.set_prop({ prop = "no_vrr", value = "toggle" }),
	{ description = "Toggle VRR for the active window (games default to VRR off)" }
)

-- GAME LAUNCHERS
hl.window_rule({
	name = "games-launchers-workspace-class",
	match = {
		class = "^(steam|lutris|com\\.heroicgameslauncher\\.hgl|heroic|org\\.prismlauncher\\.PrismLauncher|PrismLauncher|com\\.modrinth\\.theseus|ModrinthApp|com\\.atlauncher\\.ATLauncher|ATLauncher|minecraft-launcher)$",
	}, -- keep in sync with the SUPER+G matcher below
	workspace = "special:" .. C.SPECIAL_WORKSPACE.GAMES,
})

hl.bind(
	C.MODKEY .. "+G",
	toggle_app_special_workspace(C.SPECIAL_WORKSPACE.GAMES, {
		-- keep in sync with the games-launchers-workspace-class rule above
		class = {
			"^steam$",
			"^lutris$",
			"^com%.heroicgameslauncher%.hgl$",
			"^heroic$",
			"^org%.prismlauncher%.PrismLauncher$",
			"^PrismLauncher$",
			"^com%.modrinth%.theseus$",
			"^ModrinthApp$",
			"^com%.atlauncher%.ATLauncher$",
			"^ATLauncher$",
			"^minecraft%-launcher$",
		},
		title = { "^Steam$" },
	}, "steam"),
	{ description = "Toggle game launchers workspace (Steam)" }
)

hl.bind(
	C.MODKEY .. "+CTRL+G",
	hl.dsp.focus({ workspace = C.GAMES_WORKSPACE }),
	{ description = "Go to games workspace" }
)

hl.bind(
	C.MODKEY .. "+SHIFT+G",
	hl.dsp.window.move({ workspace = "special:" .. C.SPECIAL_WORKSPACE.GAMES }),
	{ description = "Move window to game launchers workspace" }
)

hl.bind(C.MODKEY .. "+ALT+G", hl.dsp.exec_cmd("heroic"), { description = "Open Heroic" })
