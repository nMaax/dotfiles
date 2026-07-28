-- KEYBINDINGS
-- See https://wiki.hypr.land/Configuring/Keywords/
-- see https://wiki.hypr.land/Configuring/Binds/ for more
-- See https://docs.noctalia.dev/v5/ipc/ for the full `noctalia msg` command list

local function ipc(args)
	return "noctalia msg " .. args
end

local function plugin_dispatch(cmd)
	return hl.dsp.exec_cmd("hyprctl dispatch " .. cmd)
end

-- 1. MAIN BINDS
hl.bind("SUPER+RETURN", hl.dsp.exec_cmd("ghostty"), { description = "Open terminal" })
hl.bind("SUPER+Q", hl.dsp.window.close({}), { description = "Kill active window" })
hl.bind("SUPER+SHIFT+Q", hl.dsp.exec_cmd("hyprctl kill"), { description = "Kill (stubborn) window under crossair" })
hl.bind(
	"SUPER+F",
	hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
	{ description = "Go fullscreen" }
)
hl.bind("SUPER+SHIFT+F", hl.dsp.window.float({ action = "toggle" }), { description = "Make active window to float" })
hl.bind("SUPER+X", function()
	local current = hl.get_config("general.layout")
	hl.config({ general = { layout = current == "scrolling" and "dwindle" or "scrolling" } })
end, { description = "Toggle scrolling/dwindle modes" })
hl.bind(
	"SUPER+ALT+CTRL+R",
	hl.dsp.exec_cmd(
		"hyprctl reload && hyprpm reload -n && "
			.. ipc("config-reload")
			.. " && "
			.. ipc("plugin kenn/keybind-cheatsheet:data all refresh")
	),
	{ description = "Reload hyprland and noctalia" }
)
hl.bind(
	"SUPER+ALT+CTRL+T",
	hl.dsp.exec_cmd("hyprctl reload && hyprpm reload -n && killall noctalia && noctalia"),
	{ description = "Reload hyprland and restart noctalia" }
)

-- Dwindle only
hl.bind("SUPER+Y", hl.dsp.layout("togglesplit"), { description = "Switch split orientation (dwindle only)" })
hl.bind(
	"SUPER+U",
	hl.dsp.window.pseudo({ action = "toggle" }),
	{ description = "Make active window to pseudo (dwindle only)" }
)

hl.bind("ALT+RETURN", hl.dsp.exec_cmd(ipc("panel-toggle launcher")), { description = "Search for apps" })
hl.bind("SUPER+V", hl.dsp.exec_cmd(ipc("panel-toggle clipboard")), { description = "Open clipboard" })
hl.bind("SUPER+period", hl.dsp.exec_cmd(ipc('panel-toggle launcher "/emo"')), { description = "Open emoji picker" })
hl.bind(
	"SUPER+SHIFT+period",
	hl.dsp.exec_cmd(ipc('panel-toggle launcher "/kao"')),
	{ description = "Open kaomoji picker" }
)
hl.bind("SUPER+BACKSPACE", hl.dsp.exec_cmd(ipc("session lock")), { description = "Lockscreen" })
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
	"SUPER+slash",
	hl.dsp.exec_cmd(ipc("panel-toggle kenn/keybind-cheatsheet:cheatsheet")),
	{ description = "Show this helping cheatsheet" }
)
hl.bind(
	"SUPER+F10",
	hl.dsp.exec_cmd(ipc("plugin noctalia/mpvpaper:service all clear-all") .. " ; pkill -f linux-wallpaperengine"),
	{ description = "Disable all animated wallpapers" }
)
hl.bind(
	"SUPER+F11",
	hl.dsp.exec_cmd("hyprctl dispatch monitor ,preferred,auto,1"),
	{ description = "Reload monitors configs" }
)
hl.bind("SUPER+Escape", hl.dsp.exec_cmd(ipc("panel-toggle session")), { description = "Open power/reboot menu" })

-- 2. APPS AND SPECIAL WORKSPACES
hl.bind("SUPER+B", hl.dsp.exec_cmd("zen-browser"), { description = "Open the zen browser" })
hl.bind("SUPER+N", hl.dsp.exec_cmd("ghostty -e nvim"), { description = "Open neovim" })
hl.bind("SUPER+SHIFT+N", hl.dsp.exec_cmd("code"), { description = "Open VSCode" })
hl.bind("SUPER+ALT+N", hl.dsp.exec_cmd("kate"), { description = "Open Kate" })
hl.bind("SUPER+E", hl.dsp.exec_cmd("dolphin"), { description = "Open dolphin file manager" })
hl.bind("SUPER+SHIFT+E", hl.dsp.exec_cmd("ghostty -e yazi"), { description = "Open yazi file manager" })

-- Specific apps keybinds
hl.bind("SUPER+D", hl.dsp.exec_cmd("discord"), { description = "Open Discord" })
hl.bind("SUPER+T", hl.dsp.exec_cmd("Telegram"), { description = "Open Telegram" })

-- Access special workspaces by toggle command
local function toggle_ws(name, matchers, command)
	return function()
		local running = false
		for _, window in ipairs(hl.get_windows()) do
			for _, pattern in ipairs(matchers.class or {}) do
				if (window.class or ""):match(pattern) then
					running = true
				end
			end
			for _, pattern in ipairs(matchers.title or {}) do
				if (window.title or ""):match(pattern) then
					running = true
				end
			end
		end
		if not running and command then
			hl.exec_cmd(command)
		end
		-- Toggle unconditionally, so the workspace slides in immediately even if
		-- the app we just spawned takes a couple of seconds to map.
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	end
end

hl.bind(
	"SUPER+Delete",
	toggle_ws("sysmon", {
		title = { "^btop$", "^nvtop$", "^htop$", "^top$" },
	}, "ghostty -e btop"),
	{ description = "Toggle system monitors workspace (btop)" }
)
-- TODO: should rather make one workspace for each app, e.g. divide telegram and discord and whatsapp
hl.bind(
	"SUPER+C",
	toggle_ws("communication", {
		class = {
			"^discord$",
			"^equibop$",
			"^vesktop$",
			"^org%.telegram%.desktop$",
			"^TelegramDesktop$",
			"^whatsapp$",
			"^Element$",
			"^signal$",
		},
		title = { "web%.whatsapp%.com" },
	}, "discord"),
	{ description = "Toggle communication workspace (Discord)" }
)
hl.bind(
	"SUPER+M",
	toggle_ws("music", {
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
	toggle_ws("games", {
		class = { "^steam$", "^lutris$", "^com%.heroicgameslauncher%.hgl$", "^heroic$" },
		title = { "^Steam$" },
	}, "steam"),
	{ description = "Toggle game launchers workspace (Steam)" }
)
hl.bind(
	"SUPER+A",
	toggle_ws("audio", {
		class = { "^easyeffects$", "^com%.github%.wwmm%.easyeffects$" },
	}, "easyeffects"),
	{ description = "Toggle audio workspace (EasyEffects)" }
)
hl.bind(
	"SUPER+P",
	toggle_ws("password", {
		class = { "^org%.keepassxc%.KeePassXC$" },
	}, "keepassxc"),
	{ description = "Toggle password workspace (KeePassXC)" }
)
hl.bind("SUPER+S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })

-- 3. MOVE AROUND (arrows)
hl.bind("SUPER+up", hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind("SUPER+down", hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })
hl.bind("SUPER+left", hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
hl.bind("SUPER+H", hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
hl.bind("SUPER+right", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })
hl.bind("SUPER+L", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })

-- Access workspaces with numbers
hl.bind("SUPER+1", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER+2", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER+3", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER+4", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER+5", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER+6", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER+7", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER+8", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER+9", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER+0", hl.dsp.focus({ workspace = "10" }), { description = "Access workspace [0-9]" })

-- Move focus around external monitors
hl.bind("SUPER+ALT+up", hl.dsp.focus({ monitor = "u" }), { description = "Move focus on monitor up" })
hl.bind("SUPER+ALT+down", hl.dsp.focus({ monitor = "d" }), { description = "Move focus on monitor down" })
hl.bind("SUPER+ALT+left", hl.dsp.focus({ monitor = "l" }), { description = "Move focus on monitor left" })
hl.bind("SUPER+ALT+right", hl.dsp.focus({ monitor = "r" }), { description = "Move focus on monitor right" })

-- Scroll workspaces with arrows and vim-keys
hl.bind(
	"SUPER+K",
	hl.dsp.focus({ workspace = "-1" }),
	{ repeating = true, description = "Scroll workspaces to the left" }
)
hl.bind(
	"SUPER+CTRL+up",
	hl.dsp.focus({ workspace = "-1" }),
	{ repeating = true, description = "Scroll workspaces to the left" }
)
hl.bind(
	"SUPER+J",
	hl.dsp.focus({ workspace = "+1" }),
	{ repeating = true, description = "Scroll workspaces to the right" }
)
hl.bind(
	"SUPER+CTRL+down",
	hl.dsp.focus({ workspace = "+1" }),
	{ repeating = true, description = "Scroll workspaces to the right" }
)

-- Scroll workspaces with mouse wheel
hl.bind(
	"SUPER+mouse_up",
	hl.dsp.focus({ workspace = "e+1" }),
	{ description = "Scroll left workspaces with mouse scroll wheel" }
)
hl.bind(
	"SUPER+mouse_down",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "Scroll right workspaces with mouse scroll wheel" }
)

-- Scroll workspaces with mouse side buttons (M4 and M5)
hl.bind("SUPER+mouse:275", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll right workspace with mouse 4" })
hl.bind("SUPER+mouse:276", hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll left workspace with mouse 5" })

-- 4. MANAGE WINDOWS
-- Move windows to workspaces with numbers
hl.bind("SUPER+SHIFT+1", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER+SHIFT+2", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER+SHIFT+3", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER+SHIFT+4", hl.dsp.window.move({ workspace = "4" }))
hl.bind("SUPER+SHIFT+5", hl.dsp.window.move({ workspace = "5" }))
hl.bind("SUPER+SHIFT+6", hl.dsp.window.move({ workspace = "6" }))
hl.bind("SUPER+SHIFT+7", hl.dsp.window.move({ workspace = "7" }))
hl.bind("SUPER+SHIFT+8", hl.dsp.window.move({ workspace = "8" }))
hl.bind("SUPER+SHIFT+9", hl.dsp.window.move({ workspace = "9" }))
hl.bind(
	"SUPER+SHIFT+0",
	hl.dsp.window.move({ workspace = "10" }),
	{ description = "Move window to workspace [0-9 | S]" }
)

-- Move windows to scratchpad
hl.bind("SUPER+SHIFT+S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move windows with SUPER CTRL arrows and vim keys
hl.bind(
	"SUPER+CTRL+SHIFT+K",
	hl.dsp.window.move({ workspace = "-1" }),
	{ repeating = true, description = "Move window to left workspace (vim, or arrows)" }
)
hl.bind("SUPER+CTRL+SHIFT+up", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
hl.bind(
	"SUPER+CTRL+SHIFT+J",
	hl.dsp.window.move({ workspace = "+1" }),
	{ repeating = true, description = "Move window to right workspace (vim, or arrows)" }
)
hl.bind("SUPER+CTRL+SHIFT+down", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })

-- Re-arrange windows with arrows
hl.bind("SUPER+SHIFT+up", hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
hl.bind("SUPER+SHIFT+down", hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
hl.bind("SUPER+SHIFT+left", hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
hl.bind("SUPER+SHIFT+H", hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
hl.bind("SUPER+SHIFT+right", hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })
hl.bind("SUPER+SHIFT+L", hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })

hl.bind(
	"SUPER+Minus",
	hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
	{ repeating = true, description = "Resize widow to the left" }
)
hl.bind(
	"SUPER+Equal",
	hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
	{ repeating = true, description = "Resize window to right" }
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
-- NOTE: mouse-drag move/resize use the dedicated no-arg dispatchers + the
-- `mouse` opt (confirmed against the official shipped example config at
-- /usr/share/hypr/hyprland.lua) -- window.move({})/drag=true (what was here
-- before) don't exist / don't validate.
hl.bind("SUPER+mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Re-arrange windows with mouse" })
hl.bind("SUPER+mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Re-size windows with mouse" })

-- Show all open workspaces
hl.bind("SUPER+TAB", plugin_dispatch("scrolloverview:overview toggle"))
hl.bind(
	"SUPER+SHIFT+TAB",
	hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"),
	{ description = "Show all open workspaces" }
)

-- Submap for scrolloverview navigation
hl.define_submap("scrolloverview", function()
	hl.bind("left", plugin_dispatch("scrolloverview:navigate left"))
	hl.bind("H", plugin_dispatch("scrolloverview:navigate left"))
	hl.bind("right", plugin_dispatch("scrolloverview:navigate right"))
	hl.bind("L", plugin_dispatch("scrolloverview:navigate right"))
	hl.bind("up", plugin_dispatch("scrolloverview:navigate up"))
	hl.bind("K", plugin_dispatch("scrolloverview:navigate up"))
	hl.bind("down", plugin_dispatch("scrolloverview:navigate down"))
	hl.bind("J", plugin_dispatch("scrolloverview:navigate down"))
	hl.bind("SUPER+TAB", plugin_dispatch("scrolloverview:overview off"))
	hl.bind("TAB", plugin_dispatch("scrolloverview:overview off"))
	hl.bind("RETURN", plugin_dispatch("scrolloverview:overview off"))
	hl.bind("Escape", plugin_dispatch("scrolloverview:overview off"))
end)

-- 5. SCREENSHOTS
hl.bind(
	"PRINT",
	hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"),
	{ description = "Take screenshot of the entire screen" }
)
hl.bind(
	"SUPER+PRINT",
	hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"),
	{ description = "Take screenshot of a selected region" }
)
hl.bind(
	"SUPER+SHIFT+PRINT",
	hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots"),
	{ description = "Take screenshot of the active window" }
)

-- 6. MULTIMEDIA
-- Laptop multimedia keys for volume and LCD brightness
-- These open the control-center at a given tab. Valid contexts per
-- `noctalia msg --help` ("panel-toggle <id> [context]"): media, audio,
-- bluetooth, notifications, system, weather, screen_time.
hl.bind(
	"SUPER+SHIFT+A",
	hl.dsp.exec_cmd(ipc("panel-toggle control-center audio")),
	{ description = "Open audio devices panel" }
)
hl.bind("SUPER+ALT+A", hl.dsp.exec_cmd(ipc("panel-toggle control-center media")), { description = "Open media panel" })
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
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc("volume-up")), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc("volume-down")), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc("volume-mute")), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc("mic-mute")), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc("brightness-up")), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc("brightness-down")), { repeating = true, locked = true })

-- Standard multimedia keys for play/pause and next/prev
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc("media next")), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc("media toggle")), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc("media toggle")), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc("media previous")), { locked = true })
