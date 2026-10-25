return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = false,
    opts = {},
    keys = {
      {
        "<leader>mp",
        function()
          require("render-markdown").preview()
        end,
        desc = "Markdown preview",
      },
      {
        "<leader>mt",
        "<cmd>RenderMarkdown toggle<CR>",
        desc = "Toggle Markdown rendering",
      },
      {
        "<leader>mx",
        function()
          local line = vim.api.nvim_get_current_line()
          local prefix, state = line:match("^(%s*[-*+]%s+)%[([ xX])%]")

          if not prefix then
            prefix, state = line:match("^(%s*%d+[.)]%s+)%[([ xX])%]")
          end

          if not prefix then
            vim.notify("No checkbox on this line", vim.log.levels.INFO)
            return
          end

          local marker = state == " " and "x" or " "
          local checkbox_start = #prefix + 1
          vim.api.nvim_set_current_line(
            line:sub(1, checkbox_start) .. marker .. line:sub(checkbox_start + 2)
          )
        end,
        ft = "markdown",
        desc = "Toggle Markdown checkbox",
      },
    },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = false,
    cmd = "Obsidian",
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "produtividade",
          path = vim.fn.expand("~/local/produtividade"),
        },
      },
      picker = { name = "telescope.nvim" },
      frontmatter = { enabled = false },
      note_id_func = function(title)
        if title then
          return title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        end
        return tostring(os.time())
      end,
      callbacks = {
        enter_note = function()
          vim.keymap.set("n", "<CR>", function()
            return require("obsidian").util.smart_action()
          end, { buffer = true, expr = true, desc = "Obsidian smart action" })
        end,
      },
    },
    keys = {
      { "<leader>nn", "<cmd>Obsidian new<CR>", desc = "New note" },
      { "<leader>ns", "<cmd>Obsidian search<CR>", desc = "Search notes" },
      { "<leader>nq", "<cmd>Obsidian quick_switch<CR>", desc = "Quick switch note" },
      { "<leader>nt", "<cmd>Obsidian today<CR>", desc = "Today's note" },
      { "<leader>nb", "<cmd>Obsidian backlinks<CR>", desc = "Backlinks" },
      { "<leader>nl", "<cmd>Obsidian links<CR>", desc = "Note links" },
      { "<leader>no", "<cmd>Obsidian open<CR>", desc = "Open in Obsidian" },
    },
  },
}
