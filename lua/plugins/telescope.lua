return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>/", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>b", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>o", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>h", "<cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<leader>lD", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "grr", "<cmd>Telescope lsp_references<CR>", desc = "References" },
      { "gri", "<cmd>Telescope lsp_implementations<CR>", desc = "Implementations" },
      { "<leader>sr", "<cmd>Telescope lsp_references<CR>", desc = "References" },
      { "<leader>ss", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>sS", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>si", "<cmd>Telescope lsp_incoming_calls<CR>", desc = "Incoming calls" },
      { "<leader>so", "<cmd>Telescope lsp_outgoing_calls<CR>", desc = "Outgoing calls" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
      { "<leader>gB", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
      { "<leader>gS", "<cmd>Telescope git_status<CR>", desc = "Git status" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          file_ignore_patterns = { "node_modules", ".git/", "dist/", ".next/" },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },
}
