local M = {}

local function is_window_on_special_workspace(window, special)
	return window.workspace ~= nil and window.workspace.name == special
end

local function split_prefix(entry)
	if entry:sub(-1) == "*" then
		return entry:sub(1, -2), true
	end
	return entry, false
end

-- Hyprland (regex) matcher for window rules
function M.regex(entries)
	local alternatives = {}
	for _, entry in ipairs(entries) do
		local name, prefix = split_prefix(entry)
		alternatives[#alternatives + 1] = name:gsub("[%.%+%*%?%(%)%|%[%]%{%}%^%$\\]", "\\%0") .. (prefix and ".*" or "")
	end
	return "^(" .. table.concat(alternatives, "|") .. ")$"
end

-- Lua patterns for matching windows from keybinds
function M.patterns(entries)
	local patterns = {}
	for _, entry in ipairs(entries) do
		local name, prefix = split_prefix(entry)
		patterns[#patterns + 1] = "^" .. name:gsub("[^%w_]", "%%%0") .. (prefix and "" or "$")
	end
	return patterns
end

-- matchers.class / matchers.title take the same plain lists as M.regex
function M.toggle_app_special_workspace(name, matchers, command)
	local special = "special:" .. name
	local class_patterns = M.patterns(matchers.class or {})
	local title_patterns = M.patterns(matchers.title or {})
	return function()
		local target
		for _, window in ipairs(hl.get_windows()) do
			local hit = false
			for _, pattern in ipairs(class_patterns) do
				if (window.class or ""):match(pattern) then
					hit = true
				end
			end
			for _, pattern in ipairs(title_patterns) do
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
