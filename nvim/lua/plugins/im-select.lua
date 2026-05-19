return {
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    opts = {
      -- 这里填“英文输入法ID”
      default_im_select = "1033",

      -- 这里填“外部命令”
      default_command = "im-select",

      -- 进入插入模式恢复之前输入法
      set_previous_events = { "InsertEnter" },

      -- 离开插入模式切回英文
      set_default_events = { "InsertLeave" },

      -- 某些 filetype 不启用
      disable_ft = { "help", "dashboard", "alpha" },
    },
  },
}
