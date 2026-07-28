-- AUTOSTART

hl.on("hyprland.start", function()
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd("/usr/lib/pam_kwallet_init")
	hl.exec_cmd("ssh-add ~/.ssh/id_ed25519")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("noctalia")
	hl.exec_cmd("mega-sync")
end)
