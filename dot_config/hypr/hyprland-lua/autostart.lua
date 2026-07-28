-- AUTOSTART
-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch
--
-- exec-once -> hl.on("hyprland.start", fn) wrapping hl.exec_cmd() calls, one
-- per original exec-once line, same order.

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    hl.exec_cmd("ssh-add ~/.ssh/id_ed25519")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- Compound line (pkill + backgrounded wl-paste watcher) kept as a single
    -- shell invocation rather than split into separate exec_cmd calls.
    hl.exec_cmd("sh -c 'pkill -9 wl-paste; wl-paste --watch cliphist store &'")
    hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("qs -c overview")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("mega-sync")
end)
