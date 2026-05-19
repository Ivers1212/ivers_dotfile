local wezterm = require("wezterm")
local constants = require("config.constants")

local M = {}

function M.apply(config)
	-- 先把你自己的字体目录加进去
	config.font_dirs = {
		constants.CONFIG_DIR .. "/fonts",
	}

	-- 用 ConfigDirsOnly
	config.font_locator = "ConfigDirsOnly"

	config.font = wezterm.font({
		family = constants.FONT_NAME or "Maple Mono NF CN",
		weight = constants.FONT_WEIGHT or "Regular",
		-- 代码字体一般不想要连字
		harfbuzz_features = {
			"calt=0",
			"clig=0",
			"liga=0",
		},
	})

	config.font_size = constants.FONT_SIZE or 12.5

	-- 代码终端常用微调
	config.line_height = 1.0
	config.cell_width = 1.0

	-- 渲染更偏清晰
	config.freetype_load_target = "Light"
	config.freetype_render_target = "HorizontalLcd"
end

return M
