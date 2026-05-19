local constants = require("config.constants")

local M = {}

function M.apply(config)
	-- 默认主题
	config.color_scheme = constants.DEFAULT_COLOR_SCHEME or "nordfox"

	-- 渲染
	config.max_fps = 120
	config.front_end = "WebGpu"
	config.webgpu_power_preference = "HighPerformance"

	-- 窗口体验
	config.window_close_confirmation = "NeverPrompt"
	config.hide_tab_bar_if_only_one_tab = true
	config.use_fancy_tab_bar = false
	config.default_cursor_style = "SteadyBar"
	config.scrollback_lines = 8000

	-- 背景保持纯不透明，避免 nvim 周围发灰
	-- config.window_background_opacity = 1.0

	-- 如需背景图，取消注释
	-- config.window_background_image = constants.CONFIG_DIR .. "/images/4.jpg"

	-- 去掉窗口留白
	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}

	-- 非活动 pane 稍微压暗一点，方便分屏时看焦点
	config.inactive_pane_hsb = {
		saturation = 0.9,
		brightness = 0.8,
	}

	-- 只覆盖少量需要的颜色
	config.colors = {
		scrollbar_thumb = "#3b4252",
		split = "#3b4252",
		compose_cursor = "#88c0d0",
	}

	-- 命令面板
	config.command_palette_bg_color = "rgba(20, 23, 31, 0.96)"
	config.command_palette_fg_color = "#d8dee9"
end

return M
