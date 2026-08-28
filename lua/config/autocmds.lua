local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

autocmd("FileType", {
  group = augroup("language_indent", { clear = true }),
  pattern = { "go" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

autocmd("FileType", {
  group = augroup("python_indent", { clear = true }),
  pattern = { "python" },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_user_command("PythonVenv", function()
  local python = require("config.python").find_python()
  if python then
    vim.notify("Python: " .. python)
  else
    vim.notify("No .venv found; using system python", vim.log.levels.WARN)
  end
end, { desc = "Show detected Python interpreter" })

autocmd("VimEnter", {
  group = augroup("cheatsheet_startup", { clear = true }),
  callback = function()
    if vim.fn.argc() > 0 or #vim.api.nvim_list_uis() == 0 then
      return
    end
    vim.schedule(function()
      require("config.cheatsheet").show()
    end)
  end,
})

vim.api.nvim_create_user_command("Cheatsheet", function()
  require("config.cheatsheet").show()
end, { desc = "Show keymap cheatsheet" })

autocmd("FileType", {
  group = augroup("q_to_close", { clear = true }),
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})
