-- ENVIRONMENT VARIABLES
-- Static session variables live in ~/.config/uwsm/env (sourced by UWSM before Hyprland).

-- NVIDIA settings for hardware acceleration
-- See https://wiki.hypr.land/Nvidia/
local function is_nvidia_gpu()
	local handle = io.popen("lspci | grep -iE 'vga|3d|display'")
	if not handle then
		return false
	end
	local output = handle:read("*a") or ""
	handle:close()
	return output:lower():find("nvidia") ~= nil
end

if is_nvidia_gpu() then
	hl.env("LIBVA_DRIVER_NAME", "nvidia")
	hl.env("NVD_BACKEND", "direct")
end
