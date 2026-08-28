-- Keep vanilla Vim motions. Space is the only extra prefix.
-- Neovim already maps: K hover, gra action, grn rename, grr refs, gri impl, [d ]d diagnostics.

local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })

map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics (loclist)" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostic" })

-- gd is not a Neovim LSP default; it is the one extra motion worth adding.
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })

map("n", "<leader>t", function()
  require("config.python").open_terminal(false)
end, { desc = "Terminal (split)" })

map("n", "<leader>T", function()
  require("config.python").open_terminal(true)
end, { desc = "Terminal (vsplit)" })

-- Leave terminal-insert without the default Ctrl-\ Ctrl-n chord.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })
