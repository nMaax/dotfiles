-- KEYBINDINGS
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
-- See https://docs.noctalia.dev/v5/ipc/ for the full `noctalia msg` command list

local C = require("lua.constants")
local ipc = C.ipc

-- 1. WINDOW ACTIONS
hl.bind(C.MODKEY .. "+Q", hl.dsp.window.close(), { description = "Kill active window" })
hl.bind(
	C.MODKEY .. "+SHIFT+Q",
	hl.dsp.exec_cmd("hyprctl kill"),
	{ description = "Kill (stubborn) window under crosshair" }
)
hl.bind(C.MODKEY .. "+F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Go fullscreen" })
hl.bind(
	C.MODKEY .. "+CTRL+F",
	hl.dsp.window.fullscreen_state({ internal = 1, client = 2, action = "toggle" }),
	{ description = "Toggle fake fullscreen (maximize, keep bars)" }
)
hl.bind(C.MODKEY .. "+ALT+F", hl.dsp.window.float({ action = "toggle" }), { description = "Make active window float" })
hl.bind(
	C.MODKEY .. "+ALT+P",
	hl.dsp.window.pin(),
	{ description = "Pin window (stick across workspaces, floating only)" }
)

-- Window groups
hl.bind(C.MODKEY .. "+C", hl.dsp.group.toggle(), { description = "Toggle window group" })
hl.bind(C.MODKEY .. "+bracketleft", hl.dsp.group.prev(), { description = "Cycle to previous window in group" })
hl.bind(C.MODKEY .. "+bracketright", hl.dsp.group.next(), { description = "Cycle to next window in group" })
hl.bind(C.MODKEY .. "+ALT+C", hl.dsp.group.lock(), { description = "Lock/unlock current group" })

local function toggle_layout()
	local current = hl.get_config("general.layout")
	hl.config({ general = { layout = current == "scrolling" and "dwindle" or "scrolling" } })
end
hl.bind(C.MODKEY .. "+X", toggle_layout, { description = "Toggle scrolling/dwindle modes" })

-- Scrolling only
hl.bind(
	C.MODKEY .. "+ALT+Equal",
	hl.dsp.layout("colresize +conf"),
	{ description = "Widen active column width (scrolling only)" }
)
hl.bind(
	C.MODKEY .. "+ALT+Minus",
	hl.dsp.layout("colresize -conf"),
	{ description = "Narrow active column width (scrolling only)" }
)
hl.bind(
	C.MODKEY .. "+SHIFT+F",
	hl.dsp.layout("fit active"),
	{ description = "Expand column into free space (scrolling only)" }
)

-- Dwindle only
hl.bind(C.MODKEY .. "+Y", hl.dsp.layout("togglesplit"), { description = "Switch split orientation (dwindle only)" })
hl.bind(
	C.MODKEY .. "+U",
	hl.dsp.window.pseudo({ action = "toggle" }),
	{ description = "Make active window pseudo (dwindle only)" }
)

-- 2. QUICK LAUNCHES
hl.bind(C.MODKEY .. "+RETURN", hl.dsp.exec_cmd(C.term()), { description = "Open terminal" })
hl.bind(C.MODKEY .. "+B", hl.dsp.exec_cmd(C.BROWSER), { description = "Open browser" })
hl.bind(C.MODKEY .. "+N", hl.dsp.exec_cmd(C.term("nvim")), { description = "Open neovim" })
hl.bind(C.MODKEY .. "+SHIFT+N", hl.dsp.exec_cmd("code"), { description = "Open VSCode" })
hl.bind(C.MODKEY .. "+ALT+N", hl.dsp.exec_cmd("gnome-text-editor"), { description = "Open Text Editor" })
hl.bind(C.MODKEY .. "+E", hl.dsp.exec_cmd(C.FILE_MANAGER), { description = "Open file manager" })
hl.bind(C.MODKEY .. "+SHIFT+E", hl.dsp.exec_cmd(C.term("yazi")), { description = "Open yazi file manager" })

-- 3. SPECIAL WORKSPACES

local special = require("lua.special")
local toggle_app_special_workspace = special.toggle_app_special_workspace

-- Toggle and move to special workspaces
for i, ws in ipairs(C.SPECIAL_WORKSPACES) do
	local toggle_action = (ws.class or ws.title)
			and toggle_app_special_workspace(ws.name, { class = ws.class, title = ws.title }, ws.cmd)
		or hl.dsp.workspace.toggle_special(ws.name)
	hl.bind(C.MODKEY .. "+" .. ws.key, toggle_action, {
		description = i == 1 and "Toggle special workspace (Delete/D/T/M/A/P/S)" or nil,
	})
	hl.bind(C.MODKEY .. "+SHIFT+" .. ws.key, hl.dsp.window.move({ workspace = "special:" .. ws.name }), {
		description = i == 1 and "Move window to special workspace (Shift+Delete/D/T/M/A/P/S)" or nil,
	})
end

-- 4. SYSTEM PANELS AND UTILITIES

-- Cheathseet and session management
hl.bind(
	C.MODKEY .. "+slash",
	hl.dsp.exec_cmd(ipc("panel-toggle kenn/keybind-cheatsheet:cheatsheet")),
	{ description = "Show this helping cheatsheet" }
)
hl.bind(C.MODKEY .. "+BACKSPACE", hl.dsp.exec_cmd(ipc("session lock")), { description = "Lockscreen" })
hl.bind(C.MODKEY .. "+Escape", hl.dsp.exec_cmd(ipc("panel-toggle session")), { description = "Open power/reboot menu" })

-- Power profile
local function toggle_power_profile()
	local cycle = io.popen(ipc("power-cycle"))
	if cycle then
		cycle:close() -- block until the cycle actually lands, so the read below isn't stale
	end
	local handle = io.popen("powerprofilesctl get")
	if not handle then
		return
	end
	local profile = handle:read("*l")
	handle:close()
	local low_power = profile == "power-saver"
	hl.config({ decoration = { blur = { enabled = not low_power }, shadow = { enabled = not low_power } } })
end
hl.bind(
	C.MODKEY .. "+ALT+B",
	toggle_power_profile,
	{ description = "Cycle power profile (blur/shadow off on power-saver)" }
)
hl.bind(
	C.MODKEY .. "+Z",
	hl.dsp.exec_cmd(ipc("caffeine-toggle")),
	{ description = "Toggle caffeine (keep screen awake)" }
)

-- Search, clipboard, and pickers
hl.bind("ALT+RETURN", hl.dsp.exec_cmd(ipc("panel-toggle launcher")), { description = "Search for apps" })
hl.bind("ALT+TAB", hl.dsp.exec_cmd(ipc("window-switcher")), { description = "Switch windows" })
hl.bind(C.MODKEY .. "+V", hl.dsp.exec_cmd(ipc("panel-toggle clipboard")), { description = "Open clipboard" })
hl.bind(
	C.MODKEY .. "+period",
	hl.dsp.exec_cmd(ipc('panel-toggle launcher "/emo"')),
	{ description = "Open emoji picker" }
)
hl.bind(
	C.MODKEY .. "+SHIFT+period",
	hl.dsp.exec_cmd(ipc('panel-toggle launcher "/kao"')),
	{ description = "Open kaomoji picker" }
)
hl.bind(C.MODKEY .. "+comma", hl.dsp.exec_cmd(ipc("settings-toggle")), { description = "Open Noctalia settings" })

-- Wallpapers and colorscheme
hl.bind(
	C.MODKEY .. "+W",
	hl.dsp.exec_cmd(ipc("panel-toggle wallpaper")),
	{ description = "Open wallpaper and colorscheme selector" }
)
hl.bind(
	C.MODKEY .. "+SHIFT+W",
	hl.dsp.exec_cmd(ipc("panel-toggle noctalia/mpvpaper:picker")),
	{ description = "Open animated wallpaper selector" }
)
hl.bind(
	C.MODKEY .. "+ALT+W",
	hl.dsp.exec_cmd(ipc("panel-toggle tadomika_ari/w-engine:w-engine-panel")),
	{ description = "Open wallpaper engine selector" }
)
hl.bind(
	C.MODKEY .. "+CTRL+W",
	hl.dsp.exec_cmd(ipc("wallpaper-random")),
	{ description = "Switch to a random wallpaper" }
)
hl.bind(
	C.MODKEY .. "+CTRL+ALT+W",
	hl.dsp.exec_cmd(ipc("plugin noctalia/mpvpaper:service all clear-all") .. " ; pkill -f linux-wallpaperengine"),
	{ description = "Disable all animated wallpapers" }
)

-- 5. NAVIGATE WORKSPACES AND FOCUS

local function vertically_aligned(before, after, direction)
	local overlaps_x = before.at.x < after.at.x + after.size.x and after.at.x < before.at.x + before.size.x
	if direction == "up" then
		return overlaps_x and after.at.y < before.at.y
	else
		return overlaps_x and after.at.y > before.at.y
	end
end

local function try_focus(window, direction)
	hl.dispatch(hl.dsp.focus({ direction = direction }))
	local after = hl.get_active_window()
	if not after or after.address == window.address then
		return nil
	end
	local same_workspace = window.workspace and after.workspace and after.workspace.name == window.workspace.name
	if same_workspace and vertically_aligned(window, after, direction) then
		return after
	end
	hl.dispatch(hl.dsp.focus({ window = window })) -- undo a cross-workspace jump or a bogus same-row match
	return nil
end

local function smart_focus(direction, workspace_delta)
	return function()
		local before = hl.get_active_window()
		if not before or not try_focus(before, direction) then
			hl.dispatch(hl.dsp.focus({ workspace = workspace_delta }))
		end
	end
end

local focus_up = smart_focus("up", "-1")
local focus_down = smart_focus("down", "+1")

--- Move focus around windows
hl.bind(C.MODKEY .. "+up", focus_up, { repeating = true })
hl.bind(
	C.MODKEY .. "+K",
	focus_up,
	{ repeating = true, description = "Move focus up, or scroll workspaces up at the edge (vim, or arrows)" }
)
hl.bind(C.MODKEY .. "+down", focus_down, { repeating = true })
hl.bind(
	C.MODKEY .. "+J",
	focus_down,
	{ repeating = true, description = "Move focus down, or scroll workspaces down at the edge (vim, or arrows)" }
)
hl.bind(C.MODKEY .. "+left", hl.dsp.focus({ direction = "left" }), {})
hl.bind(C.MODKEY .. "+H", hl.dsp.focus({ direction = "left" }), { description = "Move focus left (vim, or arrows)" })
hl.bind(C.MODKEY .. "+right", hl.dsp.focus({ direction = "right" }), {})
hl.bind(C.MODKEY .. "+L", hl.dsp.focus({ direction = "right" }), { description = "Move focus right (vim, or arrows)" })

-- Move focus around workspaces with numbers
for key = 0, 9 do
	local id = key == 0 and 10 or key
	hl.bind(C.MODKEY .. "+" .. key, special.focus_workspace(id), {
		description = key == 0 and "Access workspace [0-9]" or nil,
	})
end

-- Move focus around external monitors
local DIRECTIONS = {
	{ vim = "K", arrow = "up", dir = "u" },
	{ vim = "J", arrow = "down", dir = "d" },
	{ vim = "H", arrow = "left", dir = "l" },
	{ vim = "L", arrow = "right", dir = "r" },
}
for i, d in ipairs(DIRECTIONS) do
	hl.bind(C.MODKEY .. "+ALT+" .. d.vim, hl.dsp.focus({ monitor = d.dir }), {
		description = i == 1 and "Move focus to another monitor (vim, or arrows)" or nil,
	})
	hl.bind(C.MODKEY .. "+ALT+" .. d.arrow, hl.dsp.focus({ monitor = d.dir }), {})
end

-- Cycle window focus with mouse side buttons (M4/M5)
hl.bind(
	C.MODKEY .. "+mouse:275",
	hl.dsp.window.cycle_next({ next = false }),
	{ mouse = true, description = "Cycle focus to the previous window (mouse M4)" }
)
hl.bind(
	C.MODKEY .. "+mouse:276",
	hl.dsp.window.cycle_next({ next = true }),
	{ mouse = true, description = "Cycle focus to the next window (mouse M5)" }
)

-- Scroll workspaces with mouse wheel
hl.bind(
	C.MODKEY .. "+mouse_up",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "Scroll left workspaces with mouse scroll wheel" }
)
hl.bind(
	C.MODKEY .. "+mouse_down",
	hl.dsp.focus({ workspace = "e+1" }),
	{ description = "Scroll right workspaces with mouse scroll wheel" }
)

-- 6. MANAGE WINDOWS

local function smart_move(focus_direction, move_direction, workspace_delta)
	return function()
		local window = hl.get_active_window()
		if not window then
			return
		end
		if try_focus(window, focus_direction) then
			hl.dispatch(hl.dsp.focus({ window = window })) -- move acts on the active window
			hl.dispatch(hl.dsp.window.move({ direction = move_direction }))
		else
			hl.dispatch(hl.dsp.window.move({ workspace = workspace_delta }))
		end
	end
end

local move_up = smart_move("up", "u", "-1")
local move_down = smart_move("down", "d", "+1")

-- Move windows within workspaces
hl.bind(
	C.MODKEY .. "+SHIFT+K",
	move_up,
	{ repeating = true, description = "Move window up, or to previous workspace at the edge (vim, or arrows)" }
)
hl.bind(C.MODKEY .. "+SHIFT+up", move_up, { repeating = true })
hl.bind(
	C.MODKEY .. "+SHIFT+J",
	move_down,
	{ repeating = true, description = "Move window down, or to next workspace at the edge (vim, or arrows)" }
)
hl.bind(C.MODKEY .. "+SHIFT+down", move_down, { repeating = true })

-- Move window to workspaces with numbers
for key = 0, 9 do
	local id = key == 0 and 10 or key
	hl.bind(C.MODKEY .. "+SHIFT+" .. key, hl.dsp.window.move({ workspace = tostring(id) }), {
		description = key == 0 and "Move window to workspace [0-9]" or nil,
	})
end

-- Move all windows from one workspace to another
local function bulk_move_windows(target)
	return function()
		local current = hl.get_active_workspace()
		if not current or current.id == target then
			return
		end
		local windows = hl.get_workspace_windows(current.id)
		if #windows == 0 then
			hl.notification.create({ text = "Workspace " .. current.id .. " is empty", timeout = 2000 })
			return
		end
		for _, window in ipairs(windows) do
			hl.dispatch(hl.dsp.window.move({ workspace = tostring(target), window = window }))
		end
	end
end

for key = 0, 9 do
	local target = key == 0 and 10 or key
	hl.bind(
		C.MODKEY .. "+ALT+CTRL+" .. key,
		bulk_move_windows(target),
		{ description = key == 0 and "Move all windows of this workspace to workspace [0-9]" or nil }
	)
end

-- Re-arrange windows left/right
for _, d in ipairs({ { vim = "H", arrow = "left", dir = "l" }, { vim = "L", arrow = "right", dir = "r" } }) do
	hl.bind(C.MODKEY .. "+SHIFT+" .. d.arrow, hl.dsp.window.move({ direction = d.dir }), {})
	hl.bind(
		C.MODKEY .. "+SHIFT+" .. d.vim,
		hl.dsp.window.move({ direction = d.dir }),
		{ description = d.dir == "l" and "Move window left/right (vim, or arrows)" or nil }
	)
end

-- Resize windows
hl.bind(
	C.MODKEY .. "+Minus",
	hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
	{ repeating = true, description = "Resize window to the left" }
)
hl.bind(
	C.MODKEY .. "+Equal",
	hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
	{ repeating = true, description = "Resize window to the right" }
)
hl.bind(
	C.MODKEY .. "+SHIFT+Minus",
	hl.dsp.window.resize({ x = 0, y = -20, relative = true }),
	{ repeating = true, description = "Resize window up" }
)
hl.bind(
	C.MODKEY .. "+SHIFT+Equal",
	hl.dsp.window.resize({ x = 0, y = 20, relative = true }),
	{ repeating = true, description = "Resize window down" }
)
hl.bind(C.MODKEY .. "+mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Re-arrange windows with mouse" })
hl.bind(C.MODKEY .. "+mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize windows with mouse" })

-- 7. SCREENSHOTS
hl.bind(
	"PRINT",
	hl.dsp.exec_cmd(ipc("screenshot-fullscreen")),
	{ description = "Take screenshot of the entire screen" }
)
hl.bind(
	C.MODKEY .. "+PRINT",
	hl.dsp.exec_cmd(ipc("screenshot-region")),
	{ description = "Take screenshot of a selected region" }
)
hl.bind(
	C.MODKEY .. "+SHIFT+PRINT",
	hl.dsp.exec_cmd(ipc("screenshot-fullscreen pick")),
	{ description = "Pick a monitor to screenshot" }
)

-- 8. MULTIMEDIA

-- Panels and audio device switching
hl.bind(
	C.MODKEY .. "+XF86AudioMute",
	hl.dsp.exec_cmd('fish -c "audio-cycle --output"'),
	{ locked = true, description = "Switch audio output device" }
)
hl.bind(
	C.MODKEY .. "+SHIFT+XF86AudioMute",
	hl.dsp.exec_cmd('fish -c "audio-cycle --input"'),
	{ locked = true, description = "Switch audio input device" }
)

-- Standard multimedia keys for volume and brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(ipc("volume-up")),
	{ repeating = true, locked = true, description = "Raise volume" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(ipc("volume-down")),
	{ repeating = true, locked = true, description = "Lower volume" }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc("volume-mute")), { locked = true, description = "Mute volume" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc("mic-mute")), { locked = true, description = "Mute microphone" })
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(ipc("brightness-up")),
	{ repeating = true, locked = true, description = "Raise screen brightness" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(ipc("brightness-down")),
	{ repeating = true, locked = true, description = "Lower screen brightness" }
)

-- Brightness via volume keys, for keyboards with no dedicated brightness keys
hl.bind(
	"ALT+XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(ipc("brightness-up")),
	{ repeating = true, locked = true, description = "Raise screen brightness (volume keys)" }
)
hl.bind(
	"ALT+XF86AudioLowerVolume",
	hl.dsp.exec_cmd(ipc("brightness-down")),
	{ repeating = true, locked = true, description = "Lower screen brightness (volume keys)" }
)

-- Standard multimedia keys for play/pause and next/prev
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc("media next")), { locked = true, description = "Next track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc("media toggle")), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc("media toggle")), { locked = true, description = "Play/pause" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc("media previous")), { locked = true, description = "Previous track" })
