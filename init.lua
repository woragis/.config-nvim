-- Neovim — Tokyo Night Storm
-- Reload: :source $MYVIMRC  (or restart)

require("config.options")

-- nvim-tree replaces Neovim's built-in directory browser.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.lazy")
require("config.keymaps")
require("config.autocmds")
