------------------------------------------------------------
-- Markdown 工作流插件组
-- 目标：
--   1. render-markdown.nvim: nvim 内部渲染，接近 Obsidian/Typora 的阅读体验
--   2. markdown-preview.nvim: 浏览器预览 Mermaid / LaTeX / TOC / 图片
--   3. obsidian.nvim: 自动识别当前 Vault，支持 wiki link / backlinks / daily note
--   4. img-clip.nvim: 截图 / 剪贴板图片粘贴到 Markdown
--   5. zen-mode.nvim / twilight.nvim: 专注写作
------------------------------------------------------------

-- 向上查找 .obsidian，用于“自动识别当前 vault”
local function find_obsidian_vault()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start_dir

  if bufname ~= "" then
    start_dir = vim.fs.dirname(bufname)
  else
    start_dir = vim.fn.getcwd()
  end

  local obsidian_dir = vim.fs.find(".obsidian", {
    path = start_dir,
    upward = true,
    type = "directory",
  })[1]

  if obsidian_dir then
    return vim.fs.dirname(obsidian_dir)
  end

  -- 不在 Obsidian Vault 中时，退回当前工作目录。
  -- 这样普通 Markdown 也能使用一部分 obsidian.nvim 能力。
  return vim.fn.getcwd()
end

return {
  ----------------------------------------------------------
  -- Markdown 内联渲染
  ----------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preset = "lazy",
      render_modes = { "n", "c", "t" },

      heading = {
        enabled = true,
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },

      code = {
        enabled = true,
        sign = false,
        style = "full",
        position = "left",
        language_pad = 1,
      },

      bullet = { enabled = true },
      quote = { enabled = true },

      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 " },
          important = { raw = "[!]", rendered = " " },
          question = { raw = "[?]", rendered = " " },
        },
      },

      pipe_table = {
        enabled = true,
        preset = "round",
      },

      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip" },
        warning = { raw = "[!WARNING]", rendered = " Warning" },
        danger = { raw = "[!DANGER]", rendered = " Danger" },
        todo = { raw = "[!TODO]", rendered = "󰗡 Todo" },
      },

      completions = {
        lsp = { enabled = true },
      },
    },
  },

  ----------------------------------------------------------
  -- 浏览器预览：Mermaid / LaTeX / TOC / 图片最终效果
  ----------------------------------------------------------
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop",
    },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
    end,
  },

  ----------------------------------------------------------
  -- Obsidian Vault 集成：不写死路径，自动识别 .obsidian
  ----------------------------------------------------------
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = { "markdown" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      legacy_commands = false,

      workspaces = {
        {
          name = "auto-vault",
          path = find_obsidian_vault,
        },
      },

      -- 新笔记默认放当前目录，更适合工程文档；不强行塞进 notes/。
      notes_subdir = vim.NIL,
      new_notes_location = "current_dir",

      completion = {
        nvim_cmp = false,
        blink = true,
      },

      picker = {
        name = "snacks.pick",
      },

      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%Y-%m-%d",
      },
    },
  },

  ----------------------------------------------------------
  -- 图片粘贴：截图 / 剪贴板图片 -> assets/xxx.png
  ----------------------------------------------------------
  {
    "HakonHarnes/img-clip.nvim",
    ft = { "markdown" },
    opts = {
      default = {
        dir_path = "assets",
        file_name = "%Y-%m-%d-%H-%M-%S",
        use_absolute_path = false,
        relative_to_current_file = true,
        prompt_for_file_name = false,
      },
    },
    keys = {
      {
        "<leader>mi",
        function()
          require("img-clip").paste_image()
        end,
        desc = "Markdown Paste Image",
      },
    },
  },

  ----------------------------------------------------------
  -- 专注写作 folke/zen-mode.nvim <leader> + z(ZenMode) | t(Twilight)
  ----------------------------------------------------------
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        width = 0.82,
        options = {
          number = false,
          relativenumber = false,
          colorcolumn = "",
        },
      },
    },
  },

  {
    "folke/twilight.nvim",
    cmd = "Twilight",
  },
}
