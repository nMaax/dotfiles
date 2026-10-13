-- MONITORS
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

local C = require("lua.constants")

-- Some monitors I saw in my life
hl.monitor({
	output = "desc:Najing CEC Panda FPD Technology CO. ltd 0x004D",
	mode = "1920x1080@144",
	position = "0x0",
	scale = 1,
})
hl.monitor({ output = "desc:OOO YZ2748", mode = "1920x1080@60.00", position = "auto-up", scale = 1 })
hl.monitor({
	output = "desc:Ancor Communications Inc ASUS VN247 G2LMTF057181",
	mode = "1920x1080@60.00",
	position = "auto-up",
	scale = 1,
})
hl.monitor({
	output = "desc:Ancor Communications Inc ASUS VN247 F1LMTF033327",
	mode = "1920x1080@60.00",
	position = "auto-up",
	scale = 1,
})
hl.monitor({ output = "desc:AOC 27B36X 2RRRAHA013122", mode = "1920x1080@144.00", position = "auto-up", scale = 1 })
hl.monitor({ output = "desc:AOC 27B36X 2RRRAHA013116", mode = "1920x1080@144.00", position = "auto-up", scale = 1 })

-- Gaming monitors: vrr = 3 (fullscreen game/video only), always-on VRR flickers dark areas on OLED/VA.
-- A vrr-only change needs a restart to apply. 10 bit doesn't block direct scanout (tested).
hl.monitor({
	output = "desc:ASUSTek COMPUTER INC XG27AQDMGR T9LMTF126923",
	mode = "2560x1440@240.00",
	position = "auto-up",
	scale = 1,
	vrr = 3,
	bitdepth = 10,
})
hl.monitor({
	output = "desc:AOC Q27G41ZDF RK2S3JA009971",
	mode = "2560x1440@240.00",
	position = "auto-up",
	scale = 1,
	vrr = 3,
	bitdepth = 10,
})
hl.monitor({
	output = "desc:Samsung Electric Company LC32G7xT HNATC01677",
	mode = "2560x1440@240.00",
	position = "auto-up",
	scale = 1,
	vrr = 3,
	bitdepth = 10, -- 8 bit + FRC panel: back to 8 if dark gradients shimmer
})

-- Fallback
hl.monitor({ output = "", mode = "highrr", position = "auto-up", scale = "auto" })

-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Workspaces follow the connected monitors at runtime (laptop or desktop): with 1 monitor all sit on it,
-- with 2+ workspaces 1-5 go to the largest and 6-10 to the second, persistent. 12 and up stay unmanaged.

local WORKSPACE_GROUPS = { { 1, 2, 3, 4, 5 }, { 6, 7, 8, 9, 10 } }
local GAMES_WORKSPACE = C.GAMES_WORKSPACE

-- "Bigger" is EDID millimetres only when every monitor reports a plausible size, else pixels (never mixed).
local function ranked_monitors()
	local monitors = hl.get_monitors()

	local use_physical = true
	for _, monitor in ipairs(monitors) do
		if (monitor.physical_width or 0) < 10 or (monitor.physical_height or 0) < 10 then
			use_physical = false
		end
	end

	local function area(monitor)
		if use_physical then
			return monitor.physical_width * monitor.physical_height
		end
		return (monitor.width or 0) * (monitor.height or 0)
	end

	table.sort(monitors, function(a, b)
		if area(a) ~= area(b) then
			return area(a) > area(b)
		end
		-- Same size: assume a left-to-right arrangement and take the left one first.
		return (a.position and a.position.x or 0) < (b.position and b.position.x or 0)
	end)

	return monitors
end

local function apply_workspace_layout()
	local monitors = ranked_monitors()
	local split = #monitors >= 2

	-- Instead of trying to unpin when dropping to one monitor,
	-- pin everything to the single remaining monitor.
	for rank, group in ipairs(WORKSPACE_GROUPS) do
		local monitor = split and monitors[rank] or monitors[1]
		if monitor then
			for _, id in ipairs(group) do
				hl.workspace_rule({
					workspace = tostring(id),
					monitor = monitor.name,
					persistent = split,
				})
			end
		end
	end

	-- Games (see the games-launchers rule in gaming.lua) follow the largest screen
	if monitors[1] then
		hl.workspace_rule({
			workspace = GAMES_WORKSPACE,
			monitor = monitors[1].name,
			gaps_in = 0,
			gaps_out = 0,
			border_size = 0,
		})
	end

	-- Rules only take effect when a workspace is created, so anything already
	-- open has to be moved across explicitly.
	if not split then
		return
	end
	for rank, group in ipairs(WORKSPACE_GROUPS) do
		local monitor = monitors[rank]
		if monitor then
			for _, id in ipairs(group) do
				local workspace = hl.get_workspace(tostring(id))
				if workspace and workspace.monitor and workspace.monitor.name ~= monitor.name then
					hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))
				end
			end
		end
	end
end

apply_workspace_layout()

-- Fires on monitor add/remove, resolution or refresh change, and config reload.
hl.on("monitor.layout_changed", apply_workspace_layout)
