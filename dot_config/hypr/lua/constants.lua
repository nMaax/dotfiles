-- CONSTANTS

local M = {}

M.MODKEY = "SUPER"

M.TERMINAL = "ghostty"
M.FILE_MANAGER = "dolphin"
M.BROWSER = "zen-browser"

M.SYSMON_CLASS = "sysmon.btop"
M.PASSWORD_APP = "keepassxc"

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
		"com.heroicgameslauncher.hgl",
		"heroic",
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

return M
