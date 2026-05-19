--------------------------------------------------------------------------------
-- WezTerm Configuration
-- 模块化的 WezTerm 配置文件
-- Developer: gtiders
--------------------------------------------------------------------------------

local wezterm = require("wezterm")
local config = wezterm.config_builder()

local modules = {
	"config.fonts",
	"config.appearance",
	"config.launch_menu",
	"config.keybindings",
	"config.events",
	"config.workspace",
}

for _, name in ipairs(modules) do
	local ok, module = pcall(require, name)
	if ok and module and type(module.apply) == "function" then
		module.apply(config)
	else
		wezterm.log_error("failed to load module: " .. name)
	end
end

pcall(function()
	require("config.local").apply(config)
end)

return config
