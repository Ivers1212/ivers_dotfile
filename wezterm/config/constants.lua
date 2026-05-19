local wezterm = require("wezterm")

local M = {}

--------------------------------------------------------------------------------
-- 全局
--------------------------------------------------------------------------------

-- 当前 WezTerm 配置目录
-- 一般就是：C:/Users/Ivers/.config/wezterm
M.CONFIG_DIR = wezterm.config_dir

--------------------------------------------------------------------------------
-- 字体
--------------------------------------------------------------------------------

-- 主字体
M.FONT_NAME = "Maple Mono NF CN"

-- 建议用 Regular
-- 你之前用 Light，长时间看代码和终端日志会偏虚一点
M.FONT_WEIGHT = "Regular"

-- 字号
M.FONT_SIZE = 12.5

--------------------------------------------------------------------------------
-- 外观
--------------------------------------------------------------------------------

-- 默认主题
M.DEFAULT_COLOR_SCHEME = "nordfox"

-- 可切换主题列表
M.COLOR_SCHEMES = {
	"nordfox",
	"catppuccin-frappe",
	"Tokyo Night",
	"Gruvbox Dark",
}

--------------------------------------------------------------------------------
-- 键位
--------------------------------------------------------------------------------

-- 是否禁用 WezTerm 默认快捷键
M.DISABLE_DEFAULT_KEYS = false

-- Leader 键
M.LEADER = {
	key = "q",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}

-- pane 调整大小的步长
M.PANE_RESIZE_STEP = 5

--------------------------------------------------------------------------------
-- Shell / 启动
--------------------------------------------------------------------------------

-- 默认 shell
-- M.DEFAULT_PROG = { "pwsh.exe", "-NoLogo", "-NoProfile" }
M.DEFAULT_PROG = { "pwsh.exe", "-NoLogo" }

-- 默认 domain
M.DEFAULT_DOMAIN = "local"

--------------------------------------------------------------------------------
-- Workspace / 开发布局
--------------------------------------------------------------------------------

-- 默认 workspace 名
M.DEFAULT_WORKSPACE = "main"

-- 开发布局参数
M.DEV_LAYOUT = {
	-- 左边 nvim 占整个窗口宽度的 65%
	editor_ratio = 0.65,

	-- 右边上下两个 shell 对半分
	right_split_ratio = 0.5,

	-- 左边 pane 最终启动的命令
	editor_cmdline = "nvim",
}

--------------------------------------------------------------------------------
-- 工程入口
--------------------------------------------------------------------------------

-- 这里既给 launch_menu 用，也给 workspace 选择器用
-- 其中 workspace 字段仅供 workspace.lua 自己使用，
-- launch_menu.lua 里应该过滤掉这个字段后再传给 WezTerm
M.PROJECTS = {
	{
		label = "PowerShell - Home",
		-- args = { "pwsh.exe", "-NoLogo", "-NoProfile" },
		args = { "pwsh.exe", "-NoLogo" },
		workspace = "home",
	},
	{
		label = "PowerShell - CPrj_SideSlip",
		-- args = { "pwsh.exe", "-NoLogo", "-NoProfile" },
		args = { "pwsh.exe", "-NoLogo" },
		cwd = "F:/OneDrive/00_work/CPrj_SideSlip",
		workspace = "sideslip",
	},
	{
		label = "PowerShell - CPrj_CH395",
		-- args = { "pwsh.exe", "-NoLogo", "-NoProfile" },
		args = { "pwsh.exe", "-NoLogo" },
		cwd = "F:/OneDrive/00_work/CPrj_CH395-NET-SER-TTL422",
		workspace = "ch395",
	},
	{
		label = "PowerShell - config_Wezterm",
		-- args = { "pwsh.exe", "-NoLogo", "-NoProfile" },
		args = { "pwsh.exe", "-NoLogo" },
		cwd = "C:/Users/Ivers/.config/wezterm/",
		workspace = "wezterm",
	},
	{
		label = "PowerShell - config_Nvim",
		-- args = { "pwsh.exe", "-NoLogo", "-NoProfile" },
		args = { "pwsh.exe", "-NoLogo" },
		cwd = "C:/Users/Ivers/.config/nvim/",
		workspace = "nvim",
	},
	{
		label = "PowerShell - note",
		-- args = { "pwsh.exe", "-NoLogo", "-NoProfile" },
		args = { "pwsh.exe", "-NoLogo" },
		cwd = "F:/OneDrive/00_Obsidian@simpread/note",
		workspace = "note",
	},
}

return M
