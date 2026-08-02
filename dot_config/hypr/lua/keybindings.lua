-- KEYBINDINGS
-- See https://wiki.hypr.land/Configuring/Keywords/
-- see https://wiki.hypr.land/Configuring/Binds/ for more
-- See https://docs.noctalia.dev/v5/ipc/ for the full `noctalia msg` command list

local function ipc(args)
	return "noctalia msg " .. args
end

local function scrolloverview(dispatcher, arg)
	return function()
		local plugin = hl.plugin.scrolloverview
		if not plugin then
			hl.notification.create({ text = "scrolloverview plugin is not loaded", timeout = 2000 })
			return
		end
		local action = plugin[dispatcher](arg)
		if type(action) == "function" then
			action()
		end
	end
end

-- 1. WINDOW ACTIONS
hl.bind("SUPER+Q", hl.dsp.window.close(), { description = "Kill active window" })
hl.bind("SUPER+SHIFT+Q", hl.dsp.exec_cmd("hyprctl kill"), { description = "Kill (stubborn) window under crosshair" })
hl.bind("SUPER+F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Go fullscreen" })
hl.bind("SUPER+ALT+F", hl.dsp.window.float({ action = "toggle" }), { description = "Make active window float" })

local function toggle_layout()
	local current = hl.get_config("general.layout")
	hl.config({ general = { layout = current == "scrolling" and "dwindle" or "scrolling" } })
end
hl.bind("SUPER+X", toggle_layout, { description = "Toggle scrolling/dwindle modes" })

-- Scrolling only
hl.bind(
	"SUPER+ALT+Equal",
	hl.dsp.layout("colresize +conf"),
	{ description = "Widen active column width (scrolling only)" }
)
hl.bind("SUPER+ALT+Minus", hl.dsp.layout("colresize -conf"), {
	description = "Narrow active column width (scrolling only)",
})
hl.bind("SUPER+SHIFT+F", hl.dsp.layout("fit active"), { description = "Expand column into free space (scrolling only)" })

-- Dwindle only
hl.bind("SUPER+Y", hl.dsp.layout("togglesplit"), { description = "Switch split orientation (dwindle only)" })
hl.bind(
	"SUPER+U",
	hl.dsp.window.pseudo({ action = "toggle" }),
	{ description = "Make active window pseudo (dwindle only)" }
)

-- 2. QUICK LAUNCHES
hl.bind("SUPER+RETURN", hl.dsp.exec_cmd("ghostty"), { description = "Open terminal" })
hl.bind("SUPER+B", hl.dsp.exec_cmd("zen-browser"), { description = "Open Zen browser" })
hl.bind("SUPER+N", hl.dsp.exec_cmd("ghostty -e nvim"), { description = "Open neovim" })
hl.bind("SUPER+SHIFT+N", hl.dsp.exec_cmd("code"), { description = "Open VSCode" })
hl.bind("SUPER+ALT+N", hl.dsp.exec_cmd("kate"), { description = "Open Kate" })
hl.bind("SUPER+E", hl.dsp.exec_cmd("dolphin"), { description = "Open dolphin file manager" })
hl.bind("SUPER+SHIFT+E", hl.dsp.exec_cmd("ghostty -e yazi"), { description = "Open yazi file manager" })

-- 3. SPECIAL WORKSPACES

local function is_window_on_special_workspace(window, special)
	return window.workspace ~= nil and window.workspace.name == special
end

local function toggle_app_special_workspace(name, matchers, command)
	local special = "special:" .. name
	return function()
		local target
		for _, window in ipairs(hl.get_windows()) do
			local hit = false
			for _, pattern in ipairs(matchers.class or {}) do
				if (window.class or ""):match(pattern) then
					hit = true
				end
			end
			for _, pattern in ipairs(matchers.title or {}) do
				if (window.title or ""):match(pattern) then
					hit = true
				end
			end
			if hit then
				-- Prefer a window still on its own workspace, so a second window
				-- left elsewhere doesn't hijack the bind.
				if is_window_on_special_workspace(window, special) then
					target = window
					break
				end
				target = target or window
			end
		end

		if not target then
			if command then
				hl.exec_cmd(command)
			end
			-- Toggle unconditionally, so the workspace slides in immediately even if
			-- the app we just spawned takes a couple of seconds to map.
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
			return
		end

		local active = hl.get_active_window()
		if is_window_on_special_workspace(target, special) and active and active.address == target.address then
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
			return
		end
		hl.dispatch(hl.dsp.focus({ window = target }))
	end
end

-- Toggle a special workspace
hl.bind(
	"SUPER+Delete",
	toggle_app_special_workspace("sysmon", {
		class = { "^sysmon%.btop$" },
	}, "ghostty --class=sysmon.btop -e btop"),
	{ description = "Toggle system monitors workspace (btop)" }
)
hl.bind(
	"SUPER+D",
	toggle_app_special_workspace("discord", {
		class = { "^discord$", "^equibop$", "^vesktop$" },
	}, "discord"),
	{ description = "Toggle Discord workspace" }
)
hl.bind(
	"SUPER+T",
	toggle_app_special_workspace("telegram", {
		class = { "^org%.telegram%.desktop$", "^TelegramDesktop$" },
	}, "Telegram"),
	{ description = "Toggle Telegram workspace" }
)
hl.bind(
	"SUPER+M",
	toggle_app_special_workspace("music", {
		class = {
			"^[Ss]potify$",
			"^feishin$",
			"^Supersonic$",
			"^Cider$",
			"^com%.github%.th_ch%.youtube_music$",
			"^Plexamp$",
		},
		title = { "^Spotify$", "^Spotify Premium$", "^Spotify Free$" },
	}, "spotify"),
	{ description = "Toggle music workspace (Spotify)" }
)
hl.bind(
	"SUPER+G",
	toggle_app_special_workspace("games", {
		class = { "^steam$", "^lutris$", "^com%.heroicgameslauncher%.hgl$", "^heroic$" },
		title = { "^Steam$" },
	}, "steam"),
	{ description = "Toggle game launchers workspace (Steam)" }
)
hl.bind("SUPER+CTRL+G", hl.dsp.focus({ workspace = "11" }), { description = "Go to games workspace" })
hl.bind(
	"SUPER+A",
	toggle_app_special_workspace("ai", {
		class = {
			"^chrome%-gemini%.google%.com",
			"^chrome%-github%.com__copilot",
			"^chrome%-chatgpt%.com",
			"^chrome%-claude%.ai",
		},
	}, 'launch-webapp.sh "https://claude.ai"'),
	{ description = "Toggle AI workspace (Claude webapp)" }
)
hl.bind(
	"SUPER+P",
	toggle_app_special_workspace("password", {
		class = {
			"^org%.keepassxc%.KeePassXC$",
			"^keepassxc$",
			"^KeePass2$",
			"^[Bb]itwarden$",
			"^1[Pp]assword$",
			"^proton%-pass$",
		},
	}, "keepassxc"),
	{ description = "Toggle password workspace (KeePassXC)" }
)
hl.bind("SUPER+S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })

local function throw_to_special_workspace(name)
	return hl.dsp.window.move({ workspace = "special:" .. name })
end

hl.bind("SUPER+SHIFT+Delete", throw_to_special_workspace("sysmon"), { description = "Move window to system monitors workspace" })
hl.bind("SUPER+SHIFT+D", throw_to_special_workspace("discord"), { description = "Move window to Discord workspace" })
hl.bind("SUPER+SHIFT+T", throw_to_special_workspace("telegram"), { description = "Move window to Telegram workspace" })
hl.bind("SUPER+SHIFT+M", throw_to_special_workspace("music"), { description = "Move window to music workspace" })
hl.bind("SUPER+SHIFT+G", throw_to_special_workspace("games"), { description = "Move window to game launchers workspace" })
hl.bind("SUPER+SHIFT+A", throw_to_special_workspace("ai"), { description = "Move window to AI workspace" })
hl.bind("SUPER+SHIFT+P", throw_to_special_workspace("password"), { description = "Move window to password workspace" })
hl.bind("SUPER+SHIFT+S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to scratchpad" })

-- 4. SYSTEM PANELS AND UTILITIES

-- Cheathseet and session management
hl.bind(
	"SUPER+slash",
	hl.dsp.exec_cmd(ipc("panel-toggle kenn/keybind-cheatsheet:cheatsheet")),
	{ description = "Show this helping cheatsheet" }
)
hl.bind("SUPER+BACKSPACE", hl.dsp.exec_cmd(ipc("session lock")), { description = "Lockscreen" })
hl.bind("SUPER+Escape", hl.dsp.exec_cmd(ipc("panel-toggle session")), { description = "Open power/reboot menu" })

local function reload(level)
	-- level: 1 = hyprctl only, 2 = + hyprpm and a soft noctalia reload, 3 = kill and relaunch noctalia
	if level == 1 then
		return hl.dsp.exec_cmd("hyprctl reload")
	elseif level == 2 then
		return hl.dsp.exec_cmd(
			"hyprctl reload && hyprpm reload -n && "
				.. ipc("config-reload")
				.. " && "
				.. ipc("plugin kenn/keybind-cheatsheet:data all refresh")
		)
	else
		return hl.dsp.exec_cmd("hyprctl reload && hyprpm reload -n && killall noctalia && noctalia")
	end
end

local xsoft_reload = reload(1)
local soft_reload = reload(2)
local hard_reload = reload(3)

--- Reloading options
hl.bind("SUPER+F9", xsoft_reload, { description = "Reload hyprland only" })
hl.bind("SUPER+F10", soft_reload, { description = "Reload hyprland, soft-reload noctalia" })
hl.bind("SUPER+F11", hl.dsp.force_renderer_reload(), { description = "Reload monitor configs" })
hl.bind("SUPER+F12", hard_reload, { description = "Reload hyprland, restart noctalia" })

hl.bind("SUPER+CTRL+ALT+R", soft_reload, { description="Reload hyprland, soft-reload noctalia" }) -- alias

-- Search, clipboard, and pickers
hl.bind("ALT+RETURN", hl.dsp.exec_cmd(ipc("panel-toggle launcher")), { description = "Search for apps" })
hl.bind("ALT+TAB", hl.dsp.exec_cmd(ipc("window-switcher")), { description = "Switch windows" })
hl.bind("SUPER+V", hl.dsp.exec_cmd(ipc("panel-toggle clipboard")), { description = "Open clipboard" })
hl.bind("SUPER+period", hl.dsp.exec_cmd(ipc('panel-toggle launcher "/emo"')), { description = "Open emoji picker" })
hl.bind(
	"SUPER+SHIFT+period",
	hl.dsp.exec_cmd(ipc('panel-toggle launcher "/kao"')),
	{ description = "Open kaomoji picker" }
)
hl.bind("SUPER+comma", hl.dsp.exec_cmd(ipc("settings-toggle")), { description = "Open Noctalia settings" })

-- Wallpapers and colorscheme
hl.bind(
	"SUPER+W",
	hl.dsp.exec_cmd(ipc("panel-toggle wallpaper")),
	{ description = "Open wallpaper and colorscheme selector" }
)
hl.bind(
	"SUPER+SHIFT+W",
	hl.dsp.exec_cmd(ipc("panel-toggle noctalia/mpvpaper:picker")),
	{ description = "Open animated wallpaper selector" }
)
hl.bind(
	"SUPER+ALT+W",
	hl.dsp.exec_cmd(ipc("panel-toggle tadomika_ari/w-engine:w-engine-panel")),
	{ description = "Open wallpaper engine selector" }
)
hl.bind(
  "SUPER+CTRL+W", 
  hl.dsp.exec_cmd(ipc("wallpaper-random")), 
  { description = "Switch to a random wallpaper" }
)
hl.bind(
	"SUPER+CTRL+ALT+W",
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
hl.bind("SUPER+up", hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind(
	"SUPER+K",
	focus_up,
	{ repeating = true, description = "Move focus up, or scroll workspaces up at the edge (vim, or arrows)" }
)
hl.bind("SUPER+down", hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })
hl.bind(
	"SUPER+J",
	focus_down,
	{ repeating = true, description = "Move focus down, or scroll workspaces down at the edge (vim, or arrows)" }
)
hl.bind("SUPER+left", hl.dsp.focus({ direction = "left" }), {})
hl.bind("SUPER+H", hl.dsp.focus({ direction = "left" }), { description = "Move focus left (vim, or arrows)" })
hl.bind("SUPER+right", hl.dsp.focus({ direction = "right" }), {})
hl.bind("SUPER+L", hl.dsp.focus({ direction = "right" }), { description = "Move focus right (vim, or arrows)" })

-- Move focus around workspaces with numbers
for key = 0, 9 do
	local id = key == 0 and 10 or key
	hl.bind("SUPER+" .. key, hl.dsp.focus({ workspace = tostring(id) }), {
		description = key == 0 and "Access workspace [0-9]" or nil,
	})
end

-- Move focus around external monitors
hl.bind("SUPER+ALT+K", hl.dsp.focus({ monitor = "u" }), { description = "Move focus on monitor up (vim, or arrows)" })
hl.bind("SUPER+ALT+up", hl.dsp.focus({ monitor = "u" }), {})
hl.bind("SUPER+ALT+J", hl.dsp.focus({ monitor = "d" }), { description = "Move focus on monitor down (vim, or arrows)" })
hl.bind("SUPER+ALT+down", hl.dsp.focus({ monitor = "d" }), {})
hl.bind("SUPER+ALT+H", hl.dsp.focus({ monitor = "l" }), { description = "Move focus on monitor left (vim, or arrows)" })
hl.bind("SUPER+ALT+left", hl.dsp.focus({ monitor = "l" }), {})
hl.bind("SUPER+ALT+L", hl.dsp.focus({ monitor = "r" }), { description = "Move focus on monitor right (vim, or arrows)" })
hl.bind("SUPER+ALT+right", hl.dsp.focus({ monitor = "r" }), {})

-- Cycle window focus with mouse side buttons (M4/M5)
hl.bind(
	"SUPER+mouse:275",
	hl.dsp.window.cycle_next({ next = false }),
	{ mouse = true, description = "Cycle focus to the previous window (mouse M4)" }
)
hl.bind(
	"SUPER+mouse:276",
	hl.dsp.window.cycle_next({ next = true }),
	{ mouse = true, description = "Cycle focus to the next window (mouse M5)" }
)

-- Scroll workspaces with mouse wheel
hl.bind(
	"SUPER+mouse_up",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "Scroll left workspaces with mouse scroll wheel" }
)
hl.bind(
	"SUPER+mouse_down",
	hl.dsp.focus({ workspace = "e+1" }),
	{ description = "Scroll right workspaces with mouse scroll wheel" }
)

-- Scrolling overview
hl.bind("SUPER+TAB", scrolloverview("overview", "toggle"), { description = "Show the scrolling overview" })

-- Submap for scrolloverview navigation
hl.define_submap("scrolloverview", function()
	local navigation = {
		left = "left",
		H = "left",
		right = "right",
		L = "right",
		up = "up",
		K = "up",
		down = "down",
		J = "down",
	}
	local vim_keys = { H = true, J = true, K = true, L = true }
	for key, direction in pairs(navigation) do
		hl.bind(key, scrolloverview("navigate", direction), {
			description = vim_keys[key] and ("Move overview selection " .. direction .. " (vim, or arrows)") or nil,
		})
	end
	for _, key in ipairs({ "SUPER+TAB", "TAB", "RETURN", "Escape" }) do
		hl.bind(
			key,
			scrolloverview("overview", "off"),
			{ description = key == "Escape" and "Close the overview" or nil }
		)
	end
end)

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
	"SUPER+SHIFT+K",
	move_up,
	{ repeating = true, description = "Move window up, or to previous workspace at the edge (vim, or arrows)" }
)
hl.bind("SUPER+SHIFT+CTRL+up", move_up, { repeating = true })
hl.bind(
	"SUPER+SHIFT+J",
	move_down,
	{ repeating = true, description = "Move window down, or to next workspace at the edge (vim, or arrows)" }
)
hl.bind("SUPER+SHIFT+CTRL+down", move_down, { repeating = true })

-- Move window to workspaces with numbers
for key = 0, 9 do
	local id = key == 0 and 10 or key
	hl.bind("SUPER+SHIFT+" .. key, hl.dsp.window.move({ workspace = tostring(id) }), {
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
		"SUPER+ALT+CTRL+" .. key,
		bulk_move_windows(target),
		{ description = key == 0 and "Move all windows of this workspace to workspace [0-9]" or nil }
	)
end

-- Re-arrange windows with arrows
hl.bind("SUPER+SHIFT+up", hl.dsp.window.move({ direction = "u" }), { description = "Move window up (vim, or arrows)" })
hl.bind(
	"SUPER+SHIFT+down",
	hl.dsp.window.move({ direction = "d" }),
	{ description = "Move window down (vim, or arrows)" }
)
hl.bind("SUPER+SHIFT+left", hl.dsp.window.move({ direction = "l" }), {})
hl.bind("SUPER+SHIFT+H", hl.dsp.window.move({ direction = "l" }), { description = "Move window left (vim, or arrows)" })
hl.bind("SUPER+SHIFT+right", hl.dsp.window.move({ direction = "r" }), {})
hl.bind(
	"SUPER+SHIFT+L",
	hl.dsp.window.move({ direction = "r" }),
	{ description = "Move window right (vim, or arrows)" }
)

-- Resize windows
hl.bind(
	"SUPER+Minus",
	hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
	{ repeating = true, description = "Resize window to the left" }
)
hl.bind(
	"SUPER+Equal",
	hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
	{ repeating = true, description = "Resize window to the right" }
)
hl.bind(
	"SUPER+SHIFT+Minus",
	hl.dsp.window.resize({ x = 0, y = -20, relative = true }),
	{ repeating = true, description = "Resize window up" }
)
hl.bind(
	"SUPER+SHIFT+Equal",
	hl.dsp.window.resize({ x = 0, y = 20, relative = true }),
	{ repeating = true, description = "Resize window down" }
)
hl.bind("SUPER+mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Re-arrange windows with mouse" })
hl.bind("SUPER+mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize windows with mouse" })

-- 7. SCREENSHOTS
hl.bind(
	"PRINT",
	hl.dsp.exec_cmd(ipc("screenshot-fullscreen")),
	{ description = "Take screenshot of the entire screen" }
)
hl.bind(
	"SUPER+PRINT",
	hl.dsp.exec_cmd(ipc("screenshot-region")),
	{ description = "Take screenshot of a selected region" }
)
hl.bind(
	"SUPER+SHIFT+PRINT",
	hl.dsp.exec_cmd(ipc("screenshot-fullscreen pick")),
	{ description = "Pick a monitor to screenshot" }
)

-- 7. MULTIMEDIA

-- Panels and audio device switching
hl.bind(
	"SUPER+XF86AudioMute",
	hl.dsp.exec_cmd('fish -c "audio-cycle --output"'),
	{ locked = true, description = "Switch audio output device" }
)
hl.bind(
	"SUPER+SHIFT+XF86AudioMute",
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
