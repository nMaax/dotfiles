-- ENVIRONMENT VARIABLES
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- SSH settings
hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "") .. "/ssh-agent.socket")
hl.env("SSH_ASKPASS", "/usr/bin/ksshaskpass")
-- hl.env("SSH_ASKPASS_REQUIRE", "prefer")

-- Cursor theme and size
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

-- XDG menu prefix for desktop menus
hl.env("XDG_MENU_PREFIX", "arch-")

-- Use qt6ct for Qt platform theming and disable decorations
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- For electron apps
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- NVIDIA settings for hardware acceleration
-- See https://wiki.hypr.land/Nvidia/
local function is_nvidia_gpu()
	local handle = assert(io.popen("lspci | grep -iE 'vga|3d|display'"))
	local output = handle:read("*a")
	handle:close()
	return output:lower():find("nvidia") ~= nil
end

if is_nvidia_gpu() then
	hl.env("LIBVA_DRIVER_NAME", "nvidia")
	hl.env("NVD_BACKEND", "direct")
end
