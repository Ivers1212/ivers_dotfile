-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 行号
vim.opt.number = true
vim.opt.relativenumber = false

-- 代码默认不软换行
vim.opt.wrap = false

-- 视觉行移动更自然：j/k 按屏幕行走
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- 行宽提示
vim.opt.colorcolumn = "100"

-- 缩进显示
vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "␣",
}

-- 搜索体验
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- 光标上下保留空间
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- 分屏方向
vim.opt.splitright = true
vim.opt.splitbelow = true

-- 更新时间，影响诊断/光标悬停/一些插件响应
vim.opt.updatetime = 250

-- 更好的补全体验
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- 文件编码
vim.opt.fileencoding = "utf-8"

------------------------------------------------------------
-- Markdown / 文本类：文档编辑体验
------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    -- 中文长段落：软换行，但不自动硬断行
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = "shift:2"
    vim.opt_local.showbreak = "↪ "
    vim.opt_local.formatoptions:remove({ "t" })

    -- 文档模式：降低代码编辑器噪声
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.colorcolumn = ""
    vim.opt_local.list = false
    vim.opt_local.signcolumn = "no"

    -- 配合 render-markdown.nvim / Obsidian 链接渲染
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ""

    -- Markdown 缩进一般用 2 空格
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true

    -- 中文笔记默认不启用 spell，避免满屏英文拼写提示干扰
    vim.opt_local.spell = false
  end,
})
