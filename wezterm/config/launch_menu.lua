-- .config/wezterm/launch.lua
local constants = require("config.constants")

local M = {}

-- 复制一份 args，避免原地修改常量表
local function clone_args(args)
	local out = {}

	for _, a in ipairs(args or {}) do
		table.insert(out, a)
	end

	return out
end

-- 构造一个合法的 SpawnCommand
-- 注意：这里只能放 WezTerm launch_menu 认可的字段
-- 不能把 workspace 这种自定义字段直接塞进去
local function build_spawn_command(project)
	local args = clone_args(project.args or constants.DEFAULT_PROG)

	-- 如果是 PowerShell，并且项目定义了 cwd，
	-- 额外显式传入 -WorkingDirectory，双保险
	if project.cwd and #args > 0 and string.lower(args[1]) == "pwsh.exe" then
		table.insert(args, "-WorkingDirectory")
		table.insert(args, project.cwd)
	end

	return {
		label = project.label,
		args = args,
		cwd = project.cwd,
		domain = project.domain,
		set_environment_variables = project.set_environment_variables,
	}
end

local function build_launch_menu_items()
	local items = {}

	for _, project in ipairs(constants.PROJECTS or {}) do
		table.insert(items, build_spawn_command(project))
	end

	return items
end

function M.apply(config)
	config.default_prog = constants.DEFAULT_PROG
	config.default_domain = constants.DEFAULT_DOMAIN
	config.launch_menu = build_launch_menu_items()
end

return M
