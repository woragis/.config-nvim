-- Keep vanilla Vim motions. Space is the only extra prefix.
-- Neovim already maps: K hover, gra action, grn rename, grr refs, gri impl, [d ]d diagnostics.

local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>?", function()
  require("config.cheatsheet").show()
end, { desc = "Cheatsheet" })

map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics (loclist)" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostic" })

-- gd is not a Neovim LSP default; it is the one extra motion worth adding.
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  map("n", "<C-" .. key .. ">", "<C-w>" .. key, { desc = "Focus " .. direction .. " window" })
end

map("n", "<leader>t", function()
  require("config.python").open_terminal(false)
end, { desc = "Terminal (split)" })

map("n", "<leader>T", function()
  require("config.python").open_terminal(true)
end, { desc = "Terminal (vsplit)" })

map("n", "<leader>c", function()
  require("config.codex").open()
end, { desc = "Codex (open / focus)" })

vim.api.nvim_create_user_command("Codex", function()
  require("config.codex").open()
end, { desc = "Open or focus Codex for this project", force = true })

map("n", "<leader>rr", function()
  require("config.run").run()
end, { desc = "Run (scripts or file)" })

map("n", "<leader>rp", function()
  require("config.run").project_tasks()
end, { desc = "Project tasks" })

map("n", "<leader>rt", function()
  require("config.run").test_project()
end, { desc = "Test project" })

map("n", "<leader>rf", function()
  require("config.run").test_file()
end, { desc = "Test current file" })

-- Leave terminal-insert without the default Ctrl-\ Ctrl-n chord.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })
