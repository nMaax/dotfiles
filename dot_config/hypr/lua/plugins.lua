-- PLUGINS
-- See https://wiki.hypr.land/Plugins/Using-Plugins/
-- Always deployed, but only required with plugins = true in chezmoi.toml (hyprland.lua.tmpl).

local C = require("lua.constants")

hl.config({
	plugin = {
		scrolloverview = {
			gesture_distance = 300, -- how far is the "max" for the gesture
			scale = 0.7, -- preferred overview scale
			workspace_gap = 100,
			layout = "vertical", -- vertical or horizontal
			wallpaper = 0, -- 0: global only, 1: per-workspace only, 2: both
			blur = true, -- blur only the main overview wallpaper
			shadow = {
				enabled = true,
				range = 50,
				render_power = 3,
				color = tonumber("ee" .. C.SHADOW_HEX, 16), -- rgba(1a1a1aee) as an AARRGGBB integer
			},
		},
	},
})

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpm reload")
end)

local function scrolloverview(dispatcher, arg)
	return function()
		local plugin = hl.plugin.scrolloverview
		if not plugin then
			hl.notification.create({ text = "scrolloverview plugin is not loaded", timeout = 2000 })
			return
		end
		local action = plugin[dispatcher](arg)
		if type(action) == "function" then
			action()
		end
	end
end

-- 10. PLUGINS
-- Scrolling overview
hl.bind(C.MODKEY .. "+TAB", scrolloverview("overview", "toggle"), { description = "Show the scrolling overview" })

-- Submap for scrolloverview navigation
hl.define_submap("scrolloverview", function()
	local navigation = {
		left = "left",
		H = "left",
		right = "right",
		L = "right",
		up = "up",
		K = "up",
		down = "down",
		J = "down",
	}
	local vim_keys = { H = true, J = true, K = true, L = true }
	for key, direction in pairs(navigation) do
		hl.bind(key, scrolloverview("navigate", direction), {
			description = vim_keys[key] and ("Move overview selection " .. direction .. " (vim, or arrows)") or nil,
		})
	end
	for _, key in ipairs({ C.MODKEY .. "+TAB", "TAB", "RETURN", "Escape" }) do
		hl.bind(
			key,
			scrolloverview("overview", "off"),
			{ description = key == "Escape" and "Close the overview" or nil }
		)
	end
end)
