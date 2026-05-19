local wezterm = require("wezterm")

local M = {}

--------------------------------------------------------------------------------
-- 私有小工具
--------------------------------------------------------------------------------

-- 切换 tab bar 显示状态
-- 你的 appearance.lua 里已经设置了：
--   hide_tab_bar_if_only_one_tab = true
--   use_fancy_tab_bar = false
-- 这里通过 overrides 做“临时强制显示 / 恢复默认策略”
local function toggle_tab_bar(window)
	local overrides = window:get_config_overrides() or {}

	local is_forced_visible = overrides.enable_tab_bar == true and overrides.hide_tab_bar_if_only_one_tab == false

	if is_forced_visible then
		-- 恢复到配置文件里的默认行为
		overrides.enable_tab_bar = nil
		overrides.hide_tab_bar_if_only_one_tab = nil
	else
		-- 强制显示 tab bar
		overrides.enable_tab_bar = true
		overrides.hide_tab_bar_if_only_one_tab = false
	end

	window:set_config_overrides(overrides)
end

-- 清空所有运行时 overrides
-- 比如你后面临时切过主题、临时改过 tab bar 显示状态，
-- 都可以一把恢复回配置文件默认值
local function reset_ui_overrides(window)
	window:set_config_overrides({})
end

--------------------------------------------------------------------------------
-- 主入口
--------------------------------------------------------------------------------

function M.apply(_config)
	wezterm.on("toggle-tab-bar", function(window, _pane)
		toggle_tab_bar(window)
	end)

	wezterm.on("reset-ui-overrides", function(window, _pane)
		reset_ui_overrides(window)
	end)
end

return M
