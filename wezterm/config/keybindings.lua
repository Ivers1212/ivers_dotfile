local wezterm = require("wezterm")
local constants = require("config.constants")
local act = wezterm.action
local workspace = require("config.workspace")

local M = {}

--------------------------------------------------------------------------------
-- 小工具函数
--------------------------------------------------------------------------------

-- 统一生成一个快捷键表项
-- 这样写的好处是后面看 config.keys 时更整齐，也方便批量生成键位
local function map(key, mods, action)
	return {
		key = key,
		mods = mods,
		action = action,
	}
end

-- 生成 pane 导航键
-- 这里统一用 Ctrl + Shift + hjkl，在多个 pane 之间切换焦点
local function pane_nav_keys()
	local t = {}

	-- 左下上右四个方向的映射表
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

-- 生成 pane 大小调整键
-- 这里统一用 Ctrl+Shift + 方向键，调整当前 pane 的尺寸
-- step 表示每次调整的步长，后面你想快一点或细一点，改一个值就够了
local function pane_resize_keys(step)
	local t = {}

	local dirs = {
		{ "LeftArrow", "Left" },
		{ "DownArrow", "Down" },
		{ "UpArrow", "Up" },
		{ "RightArrow", "Right" },
	}

	for _, item in ipairs(dirs) do
		table.insert(t, map(item[1], "CTRL|SHIFT", act.AdjustPaneSize({ item[2], step })))
	end

	return t
end

-- 构建配色方案选择器的选项
-- constants.COLOR_SCHEMES 里放你允许切换的主题名
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

-- 配色方案选择器
-- 调起一个 InputSelector，让你在运行时临时切主题
-- local function pick_color_scheme_action()
-- 	return act.InputSelector({
-- 		title = "🎨 选择配色方案",
-- 		choices = build_color_scheme_choices(),
-- 		action = wezterm.action_callback(function(window, _pane, _id, label)
-- 			-- label 就是用户选择的主题名
-- 			if label then
-- 				window:set_config_overrides({
-- 					color_scheme = label,
-- 				})
-- 				wezterm.log_info("配色方案已切换为: " .. label)
-- 			end
-- 		end),
-- 	})
-- end

-- 远程粘贴动作
-- 和普通 PasteFrom 的区别是：这里是直接把剪贴板文本发送到终端程序
-- 对某些远程 Vim / Helix / TUI 程序会更直接
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
	-- 是否禁用 WezTerm 默认快捷键
	-- 你如果想完全自己接管键位，可以设成 true
	-- 如果还想保留 Ctrl+C / Ctrl+V / Ctrl+T 等默认能力，就改成 false
	config.disable_default_key_bindings = constants.DISABLE_DEFAULT_KEYS or false

	-- Leader 键
	-- 推荐把“终端管理类动作”放到 leader 层，不和 nvim / shell 常用键乱打架
	config.leader = constants.LEADER or {
		key = "q",
		mods = "CTRL",
		timeout_milliseconds = 3000,
	}

	-- 先放基础键位
	config.keys = {
		--------------------------------------------------------------------------------
		-- 窗口管理
		--------------------------------------------------------------------------------

		-- F11 切全屏
		map("F11", "NONE", act.ToggleFullScreen),

		-- LEADER + m 隐藏当前窗口
		map("m", "LEADER", act.Hide),

		--------------------------------------------------------------------------------
		-- 标签页管理
		--------------------------------------------------------------------------------

		-- 新建 tab
		map("n", "LEADER", act.SpawnTab("CurrentPaneDomain")),

		-- 关闭当前 tab
		map("w", "LEADER", act.CloseCurrentTab({ confirm = false })),

		-- 切到下一个 tab ^tab也能实现
		map("Tab", "LEADER", act.ActivateTabRelative(1)),

		-- 切换 tab bar 显示状态
		-- 前提是你在别处实现了 toggle-tab-bar 事件
		map("t", "LEADER", act.EmitEvent("toggle-tab-bar")),

		--------------------------------------------------------------------------------
		-- pane 管理
		--------------------------------------------------------------------------------

		-- 左右分屏
		map("\\", "LEADER", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),

		-- 上下分屏
		map("-", "LEADER", act.SplitVertical({ domain = "CurrentPaneDomain" })),

		-- 关闭当前 pane
		map("w", "CTRL|SHIFT", act.CloseCurrentPane({ confirm = true })),

		-- 放大 / 还原当前 pane
		map("z", "LEADER", act.TogglePaneZoomState),

		-- 调整pane大小
		-- CTRL | SHIFT + hjkl

		--------------------------------------------------------------------------------
		-- 搜索
		--------------------------------------------------------------------------------

		-- 在当前终端缓冲区中搜索
		map("/", "LEADER", act.Search("CurrentSelectionOrEmptyString")),

		--------------------------------------------------------------------------------
		-- Launch_menu
		--------------------------------------------------------------------------------

		-- 只显示 launch_menu 项
		map(
			"l",
			"LEADER",
			act.ShowLauncherArgs({
				title = "🚀 启动菜单",
				flags = "FUZZY|LAUNCH_MENU_ITEMS",
			})
		),

		-- 显示更完整的 launcher
		-- 包括 launch_menu / domains / key assignments
		map(
			"Space",
			"LEADER",
			act.ShowLauncherArgs({
				flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|KEY_ASSIGNMENTS",
			})
		),

		--------------------------------------------------------------------------------
		-- 工作区
		--------------------------------------------------------------------------------

		-- 项目 / 工作区切换器
		map("p", "LEADER", workspace.project_selector_action()),

		--------------------------------------------------------------------------------
		-- clear
		--------------------------------------------------------------------------------

		-- 清除滚动历史和当前视口内容 clear
		map("k", "LEADER", act.ClearScrollback("ScrollbackAndViewport")),

		--------------------------------------------------------------------------------
		-- 复制模式
		--------------------------------------------------------------------------------

		-- 进入复制模式
		-- 适合键盘党，类似 Vim 风格的选择和复制
		map("c", "LEADER", act.ActivateCopyMode),

		--------------------------------------------------------------------------------
		-- 滚动
		--------------------------------------------------------------------------------

		-- 快速跳到最顶
		map("Home", "LEADER", act.ScrollToTop),

		-- 快速跳到最底
		map("End", "LEADER", act.ScrollToBottom),

		--------------------------------------------------------------------------------
		-- 主题 / 域 / 粘贴
		--------------------------------------------------------------------------------

		-- 动态切换配色方案
		-- map("s", "LEADER", pick_color_scheme_action()),

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
		-- 适合支持 bracketed paste 的终端程序
		map("v", "LEADER", act.PasteFrom("Clipboard")),

		-- 直接把剪贴板文本发送到终端
		-- 对部分远程编辑器 / TUI 程序更直接
		map("V", "CTRL|SHIFT", send_clipboard_text_action()),

		--------------------------------------------------------------------------------
		-- 配置重载
		--------------------------------------------------------------------------------

		-- 重载 WezTerm 配置
		map("r", "LEADER", act.ReloadConfiguration),
	}

	--------------------------------------------------------------------------------
	-- 追加“批量生成”的键位
	--------------------------------------------------------------------------------

	-- 把 pane 导航键追加进去
	for _, k in ipairs(pane_nav_keys()) do
		table.insert(config.keys, k)
	end

	-- 把 pane resize 键追加进去
	-- 步长默认 5，你也可以在 constants.lua 里定义 PANE_RESIZE_STEP
	for _, k in ipairs(pane_resize_keys(constants.PANE_RESIZE_STEP or 5)) do
		table.insert(config.keys, k)
	end
end

return M
