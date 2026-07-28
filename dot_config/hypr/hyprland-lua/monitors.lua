-- MONITORS
-- See https://wiki.hypr.land/Configuring/Monitors/
--
-- TODO (deferred to a follow-up pass, not this 1:1 translation -- this is
-- exactly the kind of thing Lua is meant to make possible):
--  - when AsusTek is connected, use it as primary and turn off the laptop screen
--  - when laptop is not available (i.e., we are using desktop), then make it own and start from 0
--  - solve messy use of multiple workspaces on different monitors etc.

local laptop = "eDP-1"

-- Primary Monitor
hl.monitor({ output = laptop, mode = "1920x1080@144", position = "0x0", scale = 1 })

-- NOTE: you should specify here monitors where you want to turn VRR always on (most probably gaming ones)

-- Some monitor I saw in my life
hl.monitor({ output = "desc:OOO YZ2748", mode = "1920x1080@60.00", position = "auto-up", scale = 1 })
hl.monitor({ output = "desc:Ancor Communications Inc ASUS VN247 G2LMTF057181", mode = "1920x1080@60.00", position = "auto-up", scale = 1 })
hl.monitor({ output = "desc:Ancor Communications Inc ASUS VN247 F1LMTF033327", mode = "1920x1080@60.00", position = "auto-right", scale = 1 })
hl.monitor({ output = "desc:AOC 27B36X 2RRRAHA013122", mode = "1920x1080@144.00", position = "auto-up", scale = 1 })
hl.monitor({ output = "desc:AOC 27B36X 2RRRAHA013116", mode = "1920x1080@144.00", position = "auto-up", scale = 1 })

-- NOTE: for gaming we always enforce VRR, 8 bit depth is necessary to allow direct scanout to work
hl.monitor({
    output = "desc:ASUSTek COMPUTER INC XG27AQDMGR T9LMTF126923",
    mode = "2560x1440@240.00",
    position = "auto-up",
    scale = 1,
    vrr = 1,
    bitdepth = 8,
})
hl.monitor({
    output = "desc:Samsung Electric Company LC32G7xT HNATC01677",
    mode = "2560x1440@240.00",
    position = "auto",
    scale = 1,
    vrr = 1,
    bitdepth = 8,
})

-- Fallback
hl.monitor({ output = "", mode = "preferred", position = "auto-up", scale = 1 })

-- See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

-- Laptop reserved
hl.workspace_rule({ workspace = "6", monitor = laptop })
hl.workspace_rule({ workspace = "7", monitor = laptop })
hl.workspace_rule({ workspace = "8", monitor = laptop })
hl.workspace_rule({ workspace = "9", monitor = laptop })
hl.workspace_rule({ workspace = "10", monitor = laptop })

-- External reserved
-- NOTE: "m[1]" monitor-by-index selector carried over verbatim from hyprlang;
-- unconfirmed whether hl.workspace_rule's `monitor` field accepts this same
-- selector syntax -- verify at first live test.
hl.workspace_rule({ workspace = "1", monitor = "m[1]" })
hl.workspace_rule({ workspace = "2", monitor = "m[1]" })
hl.workspace_rule({ workspace = "3", monitor = "m[1]" })
hl.workspace_rule({ workspace = "4", monitor = "m[1]" })
hl.workspace_rule({ workspace = "5", monitor = "m[1]" })

-- Of course with just one monitor these do not apply
