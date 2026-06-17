local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.switcher()
	return act.ShowLauncherArgs({
		flags = "WORKSPACES",
	})
end

function M.apply(config)
	config.default_workspace = "main"
end

return M
