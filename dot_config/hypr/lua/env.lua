-- ENVIRONMENT VARIABLES
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- SSH agent socket path
hl.env("SSH_AUTH_SOCK", (os.getenv("XDG_RUNTIME_DIR") or "") .. "/ssh-agent.socket")
-- SSH askpass program for GUI prompts
hl.env("SSH_ASKPASS", "/usr/bin/ksshaskpass")
-- Prefer askpass for SSH password prompts
hl.env("SSH_ASKPASS_REQUIRE", "prefer")

-- Cursor theme
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
-- Cursor size
hl.env("HYPRCURSOR_SIZE", "24")

-- XDG menu prefix for desktop menus
hl.env("XDG_MENU_PREFIX", "arch-")

-- Use qt6ct for Qt platform theming
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- Disable window decorations in Qt Wayland
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- For electron apps
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- NVIDIA settings for hardware acceleration
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
