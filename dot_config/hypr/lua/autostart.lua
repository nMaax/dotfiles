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
    -- NOTE: v5 rewrite -- noctalia is now a standalone native binary, not a
    -- quickshell config launched via `qs -c noctalia-shell`. Confirmed:
    -- the `noctalia` package's deps no longer include noctalia-qs/quickshell
    -- at all. Per https://docs.noctalia.dev/v5/compositor-settings/hyprland/
    hl.exec_cmd("noctalia")
    -- Unrelated to noctalia -- separate quickshell config for the
    -- hyprland-scroll-overview plugin's UI, unaffected by the noctalia
    -- version change.
    hl.exec_cmd("qs -c overview")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("mega-sync")
end)
