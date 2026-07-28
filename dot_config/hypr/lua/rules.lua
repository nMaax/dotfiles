-- WINDOWS
-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more
--
-- NOTE: the original already used the newer named windowrule{} block syntax
-- (name= + match:field=), which maps closely 1:1 onto hl.window_rule({name=,
-- match={...}, ...effects}).

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

-- System Monitor workspace
hl.window_rule({
    name = "sysmon-workspace-title",
    match = { title = "^(btop|nvtop|htop|top)$" },
    workspace = "special:sysmon",
})

-- Communication workspace
hl.window_rule({
    name = "comms-workspace-class",
    match = { class = "^(discord|equibop|vesktop|org.telegram.desktop|whatsapp|Element)$" },
    workspace = "special:communication",
})

-- Password managers workspace
hl.window_rule({
    name = "password-workspace-class",
    match = { class = "^(org.keepassxc.KeePassXC)" },
    workspace = "special:password",
})

-- Audio managers workspace
hl.window_rule({
    name = "audio-workspace-class",
    match = { class = "^(easyeffects)" },
    workspace = "special:audio",
})

-- Music workspace
hl.window_rule({
    name = "music-workspace-class",
    match = { class = "^([Ss]potify|feishin|Supersonic|Cider|com.github.th_ch.youtube_music|Plexamp)$" },
    workspace = "special:music",
})
hl.window_rule({
    name = "music-workspace-title",
    match = { initial_title = "^Spotify( (Premium|Free))?$" },
    workspace = "special:music",
})

-- Small utilities (only calculator for now)
hl.window_rule({
    name = "gnome-calculator",
    match = { class = "^(org\\.gnome\\.Calculator)$" },

    -- Small, floating, and pinned regardless of the workspace
    float = true,
    size = "400 600",
    center = true,
    pin = true,
})

-- Game Launchers Workspace
hl.window_rule({
    name = "games-launchers-workspace-class",
    -- Matches Steam, Lutris, and Heroic (com.heroicgameslauncher.hgl)
    match = { class = "^(steam|lutris|com.heroicgameslauncher.hgl|heroic)$" },
    workspace = "special:games",
})

-- Games do not belong to any workspace
hl.window_rule({
    name = "games-stay-on-main-workspace",
    -- NOTE: `content` match field carried over verbatim from hyprlang's
    -- `content = game` (recognizes windows via 'content type'); the
    -- researched match-criteria list didn't explicitly enumerate `content`
    -- (only the `content_type` window *property* was documented) -- verify
    -- against the wiki's window-rules page at first live test.
    match = {
        content = "game",
        class = "^(steam_app_.*|.*\\.exe|wine|Wine|lutris_.*|heroic_.*|love)$", -- love is VRRTest
    },
    workspace = "unset",
    no_vrr = false, -- Always try to enable VRR
    idle_inhibit = "always", -- Do not sleep
})

-- Noctalia settings window
-- See https://docs.noctalia.dev/v5/compositor-settings/hyprland/
-- NOTE: class "dev.noctalia.Noctalia" is the v5 app id -- part of the v5
-- upgrade, verify once noctalia v5 is actually installed and running.
hl.window_rule({
    name = "noctalia-settings",
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})

-- Remove effects
hl.window_rule({
    name = "no-effect-overwatch",
    match = { title = "^(Overwatch)$" },

    -- Disable effects
    no_anim = true,
    no_blur = true,
    no_shadow = true,
    no_dim = true,
    rounding = 0,
    border_size = 0,
    decorate = false,
})

-- Blur Noctalia's own surfaces (bar, panels, dock, osd, window switcher, etc.)
-- See https://docs.noctalia.dev/v5/compositor-settings/hyprland/
-- NOTE: part of the v5 upgrade, verify namespace pattern once noctalia v5 is
-- actually installed and running.
hl.layer_rule({
    name = "noctalia",
    match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})
