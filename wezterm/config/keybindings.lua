local wezterm = require("wezterm")
local constants = require("config.constants")
local act = wezterm.action

local M = {}

--------------------------------------------------------------------------------
-- 小工具函数
--------------------------------------------------------------------------------

local function map(key, mods, action)
	return {
		key = key,
		mods = mods,
		action = action,
	}
end

-- Ctrl+Shift + h/j/k/l：切换 pane
local function pane_nav_keys()
	local t = {}

	local dirs = {
		{ "h", "Left" },
		{ "j", "Down" },
		{ "k", "Up" },
		{ "l", "Right" },
	}

	for _, item in ipairs(dirs) do
		table.insert(t, map(item[1], "CTRL|SHIFT", act.ActivatePaneDirection(item[2])))
	end

	return t
end

-- Ctrl+Shift+Alt + h/j/k/l：调整 pane 大小
local function pane_resize_keys(step)
	local t = {}

	local dirs = {
		{ "h", "Left" },
		{ "j", "Down" },
		{ "k", "Up" },
		{ "l", "Right" },
	}

	for _, item in ipairs(dirs) do
		table.insert(t, map(item[1], "CTRL|SHIFT|ALT", act.AdjustPaneSize({ item[2], step })))
	end

	return t
end

local function build_color_scheme_choices()
	local choices = {}

	for _, scheme in ipairs(constants.COLOR_SCHEMES or {}) do
		table.insert(choices, { label = scheme })
	end

	return choices
end

--------------------------------------------------------------------------------
-- 回调动作
--------------------------------------------------------------------------------

local function pick_color_scheme_action()
	return act.InputSelector({
		title = "🎨 选择配色方案",
		choices = build_color_scheme_choices(),
		action = wezterm.action_callback(function(window, _pane, _id, label)
			if label then
				window:set_config_overrides({
					color_scheme = label,
				})
				wezterm.log_info("配色方案已切换为: " .. label)
			end
		end),
	})
end

local function send_clipboard_text_action()
	return wezterm.action_callback(function(window, pane)
		local clipboard = window:copy_clipboard("Clipboard")

		if clipboard and clipboard ~= "" then
			pane:send_text(clipboard)
		end
	end)
end

--------------------------------------------------------------------------------
-- 主配置入口
--------------------------------------------------------------------------------

function M.apply(config)
	config.disable_default_key_bindings = constants.DISABLE_DEFAULT_KEYS or false

	config.leader = constants.LEADER or {
		key = "q",
		mods = "CTRL",
		timeout_milliseconds = 1000,
	}

	config.keys = {
		--------------------------------------------------------------------------------
		-- 窗口管理
		--------------------------------------------------------------------------------

		-- F11 切全屏
		map("F11", "NONE", act.ToggleFullScreen),

		-- LEADER + m 隐藏当前窗口
		map("m", "LEADER", act.Hide),

		--------------------------------------------------------------------------------
		-- Tab 管理
		--------------------------------------------------------------------------------

		-- 新建 tab
		map("n", "LEADER", act.SpawnTab("CurrentPaneDomain")),

		-- 关闭当前 tab
		map("w", "LEADER", act.CloseCurrentTab({ confirm = false })),

		-- Tab 导航器：多个 tab 时比 Ctrl+Tab 连按舒服
		map("Tab", "LEADER", act.ShowTabNavigator),

		-- 前后切 tab
		map("[", "LEADER", act.ActivateTabRelative(-1)),
		map("]", "LEADER", act.ActivateTabRelative(1)),

		-- 切换 tab bar 显示状态
		map("t", "LEADER", act.EmitEvent("toggle-tab-bar")),

		--------------------------------------------------------------------------------
		-- Pane 分割 / 关闭 / 放大
		--------------------------------------------------------------------------------

		-- 创建开发三布局：左侧 nvim .，右侧上下两个 shell
		-- 具体逻辑在 events.lua 的 create-dev-layout 事件里
		map("p", "LEADER", act.EmitEvent("create-dev-layout")),

		-- 手动左右分屏：右侧 35%
		map(
			"\\",
			"LEADER",
			act.SplitPane({
				direction = "Right",
				size = { Percent = 35 },
			})
		),

		-- 手动上下分屏：下侧 50%
		map(
			"-",
			"LEADER",
			act.SplitPane({
				direction = "Down",
				size = { Percent = 50 },
			})
		),

		-- 关闭当前 pane
		map("w", "CTRL|SHIFT", act.CloseCurrentPane({ confirm = true })),

		-- 放大 / 还原当前 pane
		map("z", "LEADER", act.TogglePaneZoomState),

		--------------------------------------------------------------------------------
		-- 搜索 / 启动器 / 清屏 / 复制模式
		--------------------------------------------------------------------------------

		-- 搜索当前终端缓冲区
		map("/", "LEADER", act.Search("CurrentSelectionOrEmptyString")),

		-- 完整 launcher
		map(
			"Space",
			"LEADER",
			act.ShowLauncherArgs({
				flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|KEY_ASSIGNMENTS",
			})
		),

		-- 清除滚动历史和当前视口内容
		map("k", "LEADER", act.ClearScrollback("ScrollbackAndViewport")),

		-- 进入复制模式
		map("c", "LEADER", act.ActivateCopyMode),

		--------------------------------------------------------------------------------
		-- 滚动
		--------------------------------------------------------------------------------

		map("Home", "LEADER", act.ScrollToTop),
		map("End", "LEADER", act.ScrollToBottom),

		--------------------------------------------------------------------------------
		-- 主题 / 域 / 粘贴
		--------------------------------------------------------------------------------

		-- 动态切换配色方案
		map("s", "LEADER", pick_color_scheme_action()),

		-- 打开 domain / SSH 连接选择器
		map(
			"o",
			"LEADER",
			act.ShowLauncherArgs({
				title = "🔗 SSH 连接",
				flags = "FUZZY|DOMAINS",
			})
		),

		-- 普通剪贴板粘贴
		map("v", "LEADER", act.PasteFrom("Clipboard")),

		-- 直接把剪贴板文本发送到终端
		map("V", "CTRL|SHIFT", send_clipboard_text_action()),

		--------------------------------------------------------------------------------
		-- 配置重载
		--------------------------------------------------------------------------------

		map("r", "LEADER", act.ReloadConfiguration),
	}

	--------------------------------------------------------------------------------
	-- 批量追加键位
	--------------------------------------------------------------------------------

	for _, k in ipairs(pane_nav_keys()) do
		table.insert(config.keys, k)
	end

	for _, k in ipairs(pane_resize_keys(constants.PANE_RESIZE_STEP or 5)) do
		table.insert(config.keys, k)
	end
end

return M
