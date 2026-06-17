local wezterm = require("wezterm")

local M = {}

local function create_dev_layout(window, pane)
	local tab = pane:tab()

	-- 已经分过 pane 就不重复创建
	if #tab:panes() > 1 then
		pane:activate()
		window:perform_action(wezterm.action.SendString("nvim .\r"), pane)
		return
	end

	local cwd = pane:get_current_working_dir()

	-- 右侧 shell，占 35%，左边自然剩 65%
	local right_top = pane:split({
		direction = "Right",
		size = 0.35,
		cwd = cwd,
	})

	-- 右侧上下对半分
	right_top:split({
		direction = "Bottom",
		size = 0.5,
		cwd = cwd,
	})

	-- 回到左边，自动打开 nvim .
	pane:activate()
	window:perform_action(wezterm.action.SendString("nvim .\r"), pane)
end

function M.setup()
	wezterm.on("create-dev-layout", function(window, pane)
		create_dev_layout(window, pane)
	end)
end

return M
