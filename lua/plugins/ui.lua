return {
  {
    "nvim-mini/mini.icons",
    lazy = false,
    opts = {},
    config = function(_, opts)
      require("mini.icons").setup(opts)
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 400,
      spec = {
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>n", group = "notes" },
        { "<leader>s", group = "symbols" },
        { "<leader>r", group = "run" },
        { "<leader>d", group = "debug" },
      },
    },
  },
}
