local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local constants = require("config.constants")

local M = {}

--------------------------------------------------------------------------------
-- 小工具函数
--------------------------------------------------------------------------------

-- 规范化 workspace 名字
-- 例如：
--   "PowerShell - CPrj_CH395"    -> "cprj_ch395"
--   "PowerShell - CPrj_SideSlip" -> "cprj_sideslip"
local function normalize_workspace_name(label)
	local name = label or "workspace"

	name = name:gsub("^PowerShell%s*%-%s*", "")
	name = name:gsub("%s+", "_")
	name = name:gsub("[^%w_%-]", "")
	name = name:lower()

	if name == "" then
		name = "workspace"
	end

	return name
end

-- 判断某个 workspace 是否已经存在
-- 已存在就直接切过去，不再重复创建 pane 布局
local function workspace_exists(name)
	for _, ws in ipairs(mux.get_workspace_names()) do
		if ws == name then
			return true
		end
	end
	return false
end

-- 给 InputSelector 生成项目列表
local function build_project_choices()
	local choices = {}

	for index, project in ipairs(constants.PROJECTS or {}) do
		table.insert(choices, {
			id = tostring(index),
			label = project.label,
		})
	end

	return choices
end

-- 复制一份 args，避免原地修改 constants.PROJECTS 里的内容
local function clone_args(args)
	local out = {}

	for _, a in ipairs(args or {}) do
		table.insert(out, a)
	end

	return out
end

-- 构造 shell 启动参数
-- 对 pwsh 额外补一个 -WorkingDirectory，避免只靠 cwd 传递
local function build_shell_args(project)
	local args = clone_args(project.args or constants.DEFAULT_PROG)

	if project.cwd and #args > 0 and string.lower(args[1]) == "pwsh.exe" then
		table.insert(args, "-WorkingDirectory")
		table.insert(args, project.cwd)
	end

	return args
end

--------------------------------------------------------------------------------
-- 布局创建
--------------------------------------------------------------------------------

-- 创建开发用三窗格布局
--
-- 最终布局：
--   ┌───────────────────────65%───────────────────────┬────35%────┐
--   │                                                 │   shell   │
--   │                    nvim                         ├───────────┤
--   │                                                 │   shell   │
--   └─────────────────────────────────────────────────┴───────────┘
--
-- 注意：
-- 我们先把三个 pane 都创建好，最后再在左边执行 nvim。
-- 这样可以避免 nvim 在窗口尺寸还没稳定时先画 dashboard，
-- 从而出现你之前看到的“header 割裂”问题。
local function create_dev_layout(project)
	local workspace_name = project.workspace or normalize_workspace_name(project.label)
	local cwd = project.cwd
	local shell_args = build_shell_args(project)

	-- 1) 先创建左侧 pane：先开 shell，不直接开 nvim
	--    后面等布局稳定后，再让它执行 nvim
	local _, left_pane, _ = mux.spawn_window({
		workspace = workspace_name,
		cwd = cwd,
		args = shell_args,
	})

	-- 2) 从左侧 pane 向右切出一个新 pane
	--    这里 size = 0.35，表示“新切出来的右侧 pane 占整屏 35%”
	--    因此左侧剩下 65%，正好给 nvim
	local top_right = left_pane:split({
		direction = "Right",
		size = 1 - (constants.DEV_LAYOUT.editor_ratio or 0.65),
		cwd = cwd,
		args = shell_args,
	})

	-- 3) 再把右上 pane 向下切一刀
	--    右侧上下各占一半
	top_right:split({
		direction = "Bottom",
		size = constants.DEV_LAYOUT.right_split_ratio or 0.5,
		cwd = cwd,
		args = shell_args,
	})

	-- 4) 把焦点切回左边 pane
	left_pane:activate()

	-- 5) 最后再启动 nvim
	--    这一步放到最后，就是为了避免 dashboard 在 split 前先渲染
	left_pane:send_text((constants.DEV_LAYOUT.editor_cmdline or "nvim") .. "\r")
	-- 6) 显式激活这个 workspace
	mux.set_active_workspace(workspace_name)
end

-- 创建一个普通 workspace
-- 用于像 Home 这种没有 cwd、不需要三窗格开发布局的项目
local function create_simple_workspace(project)
	local workspace_name = project.workspace or normalize_workspace_name(project.label)
	local cwd = project.cwd
	local shell_args = build_shell_args(project)

	mux.spawn_window({
		workspace = workspace_name,
		cwd = cwd,
		args = shell_args,
	})

	mux.set_active_workspace(workspace_name)
end

--------------------------------------------------------------------------------
-- 工作区切换逻辑
--------------------------------------------------------------------------------

-- 切换或创建项目 workspace
local function switch_or_create_project_workspace(window, pane, project)
	if not project then
		return
	end

	local workspace_name = project.workspace or normalize_workspace_name(project.label)

	-- 如果 workspace 已存在，直接切过去，不重建布局
	if workspace_exists(workspace_name) then
		window:perform_action(
			act.SwitchToWorkspace({
				name = workspace_name,
			}),
			pane
		)
		return
	end

	-- 如果没有 cwd，就走普通 workspace
	-- 比如 "PowerShell - Home" 这种，不适合强行套开发布局
	if not project.cwd or project.cwd == "" then
		create_simple_workspace(project)
		return
	end

	-- 有 cwd 的工程项目，走三窗格开发布局
	create_dev_layout(project)
end

--------------------------------------------------------------------------------
-- 对外动作
--------------------------------------------------------------------------------

-- 项目 / 工作区选择器
-- 由 keybindings.lua 里的 leader + g 调起
function M.project_selector_action()
	return act.InputSelector({
		title = "🧰 选择工作区 / 工程",
		choices = build_project_choices(),
		fuzzy = true,
		action = wezterm.action_callback(function(window, pane, id, _label)
			if not id then
				return
			end

			local project = constants.PROJECTS[tonumber(id)]
			switch_or_create_project_workspace(window, pane, project)
		end),
	})
end

--------------------------------------------------------------------------------
-- 主入口
--------------------------------------------------------------------------------

function M.apply(config)
	-- 默认 workspace 名
	config.default_workspace = constants.DEFAULT_WORKSPACE or "main"
end

return M
