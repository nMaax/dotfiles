-- CONSTANTS

local M = {}

local function read_default_terminal()
	local path = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/default-terminal"
	local f = io.open(path, "r")
	if f then
		local term = f:read("*l")
		f:close()
		if term and term ~= "" then
			return term
		end
	end
	return os.getenv("TERMINAL") or "ghostty"
end

M.MODKEY = "SUPER"

M.TERMINAL = read_default_terminal()
M.FILE_MANAGER = "dolphin"
M.BROWSER = "zen-browser"

M.SYSMON_CLASS = "sysmon.btop"
M.PASSWORD_APP = "keepassxc"
M.HEROIC_CLASSES = { "com.heroicgameslauncher.hgl", "heroic" }

M.GAMES_WORKSPACE = "11"

M.SPECIAL_WORKSPACE = {
	SYSMON = "sysmon",
	DISCORD = "discord",
	TELEGRAM = "telegram",
	MUSIC = "music",
	GAMES = "games",
	AI = "ai",
	PASSWORD = "password",
	MAGIC = "magic",
}

-- Window classes per special workspace; a trailing "*" means "starts with".
-- lua/special.lua turns them into the Hyprland regex (rules.lua) and the Lua patterns (keybindings.lua).
M.APP_CLASSES = {
	SYSMON = { M.SYSMON_CLASS },
	DISCORD = { "discord", "equibop", "vesktop" },
	TELEGRAM = { "org.telegram.desktop", "TelegramDesktop" },
	MUSIC = { "Spotify", "spotify", "feishin", "Supersonic", "Cider", "com.github.th_ch.youtube_music", "Plexamp" },
	AI = { "chrome-gemini.google.com*", "chrome-github.com__copilot*", "chrome-chatgpt.com*", "chrome-claude.ai*", "Claude" },
	PASSWORD = {
		"org.keepassxc.KeePassXC",
		"keepassxc",
		"KeePass2",
		"Bitwarden",
		"bitwarden",
		"1Password",
		"1password",
		"Enpass",
		"proton-pass",
		"org.kde.kwalletmanager5",
		"org.gnome.Seahorse",
		"org.gnome.World.Secrets",
	},
	GAMES = {
		"steam",
		"lutris",
		M.HEROIC_CLASSES[1],
		M.HEROIC_CLASSES[2],
		"org.prismlauncher.PrismLauncher",
		"PrismLauncher",
		"com.modrinth.theseus",
		"ModrinthApp",
		"com.atlauncher.ATLauncher",
		"ATLauncher",
		"minecraft-launcher",
	},
}
M.MUSIC_TITLES = { "Spotify", "Spotify Premium", "Spotify Free" }
M.GAMES_TITLES = { "Steam" }

M.SHADOW_HEX = "1a1a1a"

function M.ipc(args)
	return "noctalia msg " .. args
end

function M.term(cmd, class)
	local parts = { M.TERMINAL }
	if class then
		local flag = M.TERMINAL == "foot" and "--app-id=" or "--class="
		parts[#parts + 1] = flag .. class
	end
	if cmd then
		parts[#parts + 1] = "-e " .. cmd
	end
	return table.concat(parts, " ")
end

return M
