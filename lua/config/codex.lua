local M = {}
local sessions = {}

function M.open()
  if vim.fn.executable("codex") ~= 1 then
    vim.notify("Codex CLI is not on Neovim's PATH", vim.log.levels.ERROR)
    return
  end

  local root = vim.b.codex_root or vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  local session = sessions[root]
  if session and vim.api.nvim_buf_is_valid(session.buf)
      and vim.fn.jobwait({ session.job }, 0)[1] == -1 then
    local win = vim.fn.bufwinid(session.buf)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
    else
      vim.cmd("botright vsplit")
      vim.api.nvim_win_set_buf(0, session.buf)
    end
    vim.cmd("startinsert")
    return
  end

  vim.cmd("botright vnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "hide"
  vim.b[buf].codex_root = root
  local job = vim.fn.jobstart({ "codex" }, { term = true, cwd = root })
  if job <= 0 then
    vim.notify("Could not start Codex CLI", vim.log.levels.ERROR)
    return
  end
  sessions[root] = { buf = buf, job = job }
  vim.cmd("startinsert")
end

return M
