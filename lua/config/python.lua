local M = {}

local function python_in(dir)
  for _, name in ipairs({ ".venv", "venv" }) do
    local python = dir .. "/" .. name .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      return python
    end
  end
  return nil
end

function M.find_python(root)
  if vim.env.VIRTUAL_ENV then
    local active = vim.env.VIRTUAL_ENV .. "/bin/python"
    if vim.fn.executable(active) == 1 then
      return active
    end
  end

  root = root
    or vim.fs.root(0, { "pyproject.toml", "setup.py", "requirements.txt", "Pipfile", ".git" })
    or vim.fn.getcwd()

  return python_in(root)
end

function M.venv_dir(python)
  if not python then
    return nil
  end
  return vim.fn.fnamemodify(python, ":h:h")
end

function M.term_env()
  local env = vim.fn.environ()
  local python = M.find_python()
  if python then
    local venv = M.venv_dir(python)
    env.VIRTUAL_ENV = venv
    env.PATH = venv .. "/bin:" .. (env.PATH or "")
  end
  return env
end

function M.open_terminal(vertical)
  if vertical then
    vim.cmd("vsplit")
  else
    vim.cmd("botright split")
    vim.cmd("resize 12")
  end
  vim.fn.jobstart(vim.o.shell, { term = true, env = M.term_env() })
  vim.cmd("startinsert")
end

return M
