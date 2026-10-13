local M = {}

local function is_window_on_special_workspace(window, special)
	return window.workspace ~= nil and window.workspace.name == special
end

function M.toggle_app_special_workspace(name, matchers, command)
	local special = "special:" .. name
	return function()
		local target
		for _, window in ipairs(hl.get_windows()) do
			local hit = false
			for _, pattern in ipairs(matchers.class or {}) do
				if (window.class or ""):match(pattern) then
					hit = true
				end
			end
			for _, pattern in ipairs(matchers.title or {}) do
				if (window.title or ""):match(pattern) then
					hit = true
				end
			end
			if hit then
				-- Prefer a window still on its own workspace, so a second window
				-- left elsewhere doesn't hijack the bind.
				if is_window_on_special_workspace(window, special) then
					target = window
					break
				end
				target = target or window
			end
		end

		if not target then
			if command then
				hl.exec_cmd(command)
			end
			-- Toggle unconditionally, so the workspace slides in immediately even if
			-- the app we just spawned takes a couple of seconds to map.
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
			return
		end

		local active = hl.get_active_window()
		if is_window_on_special_workspace(target, special) and active and active.address == target.address then
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
			return
		end
		hl.dispatch(hl.dsp.focus({ window = target }))
	end
end

return M
