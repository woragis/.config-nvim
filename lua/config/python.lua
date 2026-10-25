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

function M.term_env(root)
  local env = vim.fn.environ()
  local python = M.find_python(root)
  if python then
    local venv = M.venv_dir(python)
    env.VIRTUAL_ENV = venv
    env.PATH = venv .. "/bin:" .. (env.PATH or "")
  end
  return env
end

function M.open_terminal(vertical)
  local env = M.term_env()
  if vertical then
    vim.cmd("vnew")
  else
    vim.cmd("botright new")
    vim.cmd("resize 12")
  end
  vim.fn.jobstart(vim.o.shell, { term = true, env = env })
  vim.cmd("startinsert")
end

local function python_exe()
  return M.find_python() or vim.fn.exepath("python3") or "python3"
end

local function run_in_split(cmd)
  vim.cmd("botright split")
  vim.cmd("resize 12")
  vim.fn.jobstart(cmd, { term = true, env = M.term_env() })
  vim.cmd("startinsert")
end

function M.run_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  run_in_split({ python_exe(), file })
end

function M.pytest_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to test", vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  run_in_split({ python_exe(), "-m", "pytest", file })
end

function M.pytest_project()
  local root = vim.fs.root(0, { "pyproject.toml", "pytest.ini", "setup.py", ".git" }) or vim.fn.getcwd()
  run_in_split({ python_exe(), "-m", "pytest", root })
end

return M
