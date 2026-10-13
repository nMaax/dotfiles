-- AUTOSTART
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
	hl.exec_cmd("ssh-add ~/.ssh/id_ed25519")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("noctalia")
	hl.exec_cmd("command -v mega-sync && mega-sync") -- not installed when mega_authkey = false
end)
