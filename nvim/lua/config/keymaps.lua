-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

------------------------------------------------------------
-- Markdown 专用快捷键
------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
    end

    local function insert_lines(lines, cursor_up)
      cursor_up = cursor_up or 0
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, row, row, false, lines)
      vim.api.nvim_win_set_cursor(0, { row + #lines - cursor_up, 0 })
      vim.cmd("startinsert!")
    end

    -- 浏览器预览 / nvim 内渲染
    map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", "Markdown Preview")
    map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", "Markdown Render Toggle")
    map("n", "<leader>mR", "<cmd>RenderMarkdown buf_toggle<cr>", "Markdown Render Toggle Buffer")

    -- 专注写作
    map("n", "<leader>mz", "<cmd>ZenMode<cr>", "Markdown Zen Mode")
    map("n", "<leader>mt", "<cmd>Twilight<cr>", "Markdown Twilight")

    -- Obsidian 常用命令
    map("n", "<leader>mo", "<cmd>Obsidian quick_switch<cr>", "Obsidian Quick Switch")
    map("n", "<leader>mb", "<cmd>Obsidian backlinks<cr>", "Obsidian Backlinks")
    map("n", "<leader>md", "<cmd>Obsidian today<cr>", "Obsidian Today")
    map("n", "<leader>mf", "<cmd>Obsidian follow_link<cr>", "Obsidian Follow Link")

    -- 图片粘贴
    map("n", "<leader>mi", function()
      require("img-clip").paste_image()
    end, "Markdown Paste Image")

    -- 常用 code fence
    map("n", "<leader>mc", function()
      insert_lines({ "```c", "", "```" }, 1)
    end, "Markdown Code Fence C")

    map("n", "<leader>mC", function()
      insert_lines({ "```cmake", "", "```" }, 1)
    end, "Markdown Code Fence CMake")

    map("n", "<leader>ml", function()
      insert_lines({ "```lua", "", "```" }, 1)
    end, "Markdown Code Fence Lua")

    map("n", "<leader>ms", function()
      insert_lines({ "```bash", "", "```" }, 1)
    end, "Markdown Code Fence Shell")

    map("n", "<leader>mm", function()
      insert_lines({ "```mermaid", "flowchart TD", "  A[入口] --> B[模块]", "  B --> C[输出]", "```" }, 1)
    end, "Markdown Mermaid Flowchart")

    -- Callout
    map("n", "<leader>mn", function()
      insert_lines({ "> [!NOTE]", "> " }, 0)
    end, "Markdown Callout Note")

    map("n", "<leader>mw", function()
      insert_lines({ "> [!WARNING]", "> " }, 0)
    end, "Markdown Callout Warning")

    map("n", "<leader>mT", function()
      insert_lines({ "> [!TIP]", "> " }, 0)
    end, "Markdown Callout Tip")

    -- Checkbox
    map("n", "<leader>mx", function()
      insert_lines({ "- [ ] " }, 0)
    end, "Markdown Checkbox")
  end,
})
