-- GAMING
-- Always deployed, but only required with gaming = true in chezmoi.toml (hyprland.lua.tmpl).

local C = require("lua.constants")
local special = require("lua.special")
local ipc = C.ipc

-- PERFORMANCE
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/#vrr

-- VRR is preferred over tearing (smoother frametimes, ~no extra latency), but on OLED/VA panels it
-- flickers dark scenes when FPS fluctuates, so games default to VRR off; SUPER+ALT+V toggles it.

hl.config({
	general = {
		-- Capability switch only: a window must also be fullscreen with an 'immediate' rule to tear
		allow_tearing = false,
	},

	cursor = {
		-- 0 = keep hardware cursors on, required for direct scanout
		no_hardware_cursors = 0,

		-- Hardware cursors on Nvidia need a CPU buffer (2 = auto)
		use_cpu_buffer = 2,

		-- Avoids framerate spikes on cursor movement in VRR fullscreen (2 = auto, on for 'game')
		no_break_fs_vrr = 2,
	},

	render = {
		-- 2 = auto (on for content type 'game'). A native-Wayland game with a black screen (e.g. Overwatch)
		-- should run on XWayland instead: losing direct scanout is worse.
		direct_scanout = 2,
	},

	misc = {
		-- 3 = fullscreen video/games only; monitors.lua sets the same per monitor
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
	no_vrr = true, -- OLED flicker, see PERFORMANCE; SUPER+ALT+V re-enables it per game
	idle_inhibit = "always", -- Do not sleep
	content = "game", -- many games never self-report it, and direct_scanout/vrr/game mode key off it
	confine_pointer = true, -- Keep the cursor on this monitor -- this is a multi-monitor rig
})

-- Competitive games get VRR on (cap FPS in-game). set_prop, not a rule: a second rule can't override no_vrr above.
local COMPETITIVE_GAMES = {
	steam_app_2357570 = true, -- Overwatch
}
hl.on("window.open", function(window)
	if COMPETITIVE_GAMES[window.class] then
		hl.dispatch(hl.dsp.window.set_prop({ prop = "no_vrr", value = "false", window = window }))
	end
end)

-- 9. GAMING
-- Game mode mutes OSD/notifications and forces dwindle: a layer surface mapping drops the pointer lock
-- on a hidden scrolling workspace (hyprwm/Hyprland#16326). Auto on/off with the first/last game window.
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
		hl.exec_cmd(ipc("osd-disable"))
		hl.exec_cmd(ipc("notification-dnd-set true"))
		layout_before_game_mode = hl.get_config("general.layout")
		hl.config({ general = { layout = "dwindle" } })
		hl.notification.create({ text = "🎮 Game Mode: ON (OSD & Notifications disabled, dwindle)", timeout = 2500 })
	else
		hl.exec_cmd(ipc("osd-enable"))
		hl.exec_cmd(ipc("notification-dnd-set false"))
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
	-- game_mode_auto first: dnd is set asynchronously, so a second game window could still read it as off
	if window.content_type == "game" and not game_mode_auto and not dnd_on() then
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
	match = { class = special.regex(C.APP_CLASSES.GAMES) },
	workspace = "special:" .. C.SPECIAL_WORKSPACE.GAMES,
})

hl.bind(
	C.MODKEY .. "+G",
	special.toggle_app_special_workspace(
		C.SPECIAL_WORKSPACE.GAMES,
		{ class = C.APP_CLASSES.GAMES, title = C.GAMES_TITLES },
		"steam"
	),
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
