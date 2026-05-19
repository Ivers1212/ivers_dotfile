------------------------------------------------------------
-- 模板系统（BufNewFile 自动插入模板）
-- 用途：
--   :e main.c  → 自动填充 c_template.c
--   :e foo.h   → 自动填充 h_template.h
--   snack explore → BufReadPost 空文件
-- 优点：
--   ✔ 解耦 init.lua（保持入口干净）
--   ✔ 支持扩展（后面加 .s / CMake 很方便）
--   ✔ 路径可移植（不写死用户目录）
------------------------------------------------------------

-- 获取 nvim 配置目录（跨平台）
-- Windows: C:/Users/xxx/AppData/Local/nvim
-- Linux  : ~/.config/nvim
local template_dir = vim.fn.stdpath("config") .. "/templates/"

------------------------------------------------------------
-- 模板映射表
-- key   = 文件扩展名
-- value = 对应模板文件
------------------------------------------------------------
local templates = {
  c = "c_template.c",
  h = "h_template.h",
  md = "md_engineering.md",

  -- 后续可以扩展：
  -- s = "asm_template.s",
  -- txt = "txt_template.txt",
}

------------------------------------------------------------
-- 判断当前 buffer 是否为空
------------------------------------------------------------
local function is_empty_buffer()
  return vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == ""
end

------------------------------------------------------------
-- 判断当前文件是否是磁盘上的 0 字节文件
------------------------------------------------------------
local function is_zero_size_file(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.size == 0
end

------------------------------------------------------------
-- 插入模板
------------------------------------------------------------
local function insert_template()
  local ext = vim.fn.expand("%:e")
  local template_file = templates[ext]

  if not template_file then
    return
  end

  -- 防止重复插入
  if vim.b.template_inserted then
    return
  end

  local file_path = vim.fn.expand("%:p")

  -- 只给空 buffer / 0 字节文件插模板
  if not is_empty_buffer() then
    return
  end

  if vim.fn.filereadable(file_path) == 1 and not is_zero_size_file(file_path) then
    return
  end

  local template_path = template_dir .. template_file

  if vim.fn.filereadable(template_path) == 0 then
    vim.notify("Template not found: " .. template_path, vim.log.levels.WARN)
    return
  end

  local content = vim.fn.readfile(template_path)

  -- 模板变量替换
  local filename = vim.fn.expand("%:t")
  local guard = string.upper(filename):gsub("[^A-Z0-9]", "_")
  local title = filename:gsub("%.md$", "")

  content = vim.tbl_map(function(line)
    line = line:gsub("{{FILENAME}}", filename)
    line = line:gsub("{{GUARD}}", guard)
    line = line:gsub("{{TITLE}}", title)
    return line
  end, content)

  vim.api.nvim_buf_set_lines(0, 0, -1, false, content)

  vim.b.template_inserted = true
end

------------------------------------------------------------
-- 关键点：
-- BufNewFile  处理 :e xxx.c
-- BufReadPost 处理 snacks.nvim explorer 新建后的空文件
------------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = { "*.c", "*.h", "*.md" },
  callback = insert_template,
})
