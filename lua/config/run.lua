local M = {}

local function exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

local function add_task(tasks, label, cmd, cwd, env)
  table.insert(tasks, { label = label, cmd = cmd, cwd = cwd, env = env })
end

local function add_javascript_tasks(tasks)
  local js = require("config.javascript")
  local root = js.root()
  local pkg = root and js.read_package(root)
  local scripts = pkg and pkg.scripts
  if not root or not scripts then
    return
  end

  for _, name in ipairs(vim.tbl_keys(scripts)) do
    add_task(tasks, "JavaScript: " .. name, js.script_command(root, name), root, js.term_env(root))
  end
end

local function add_python_tasks(tasks)
  local root = vim.fs.root(0, { "pyproject.toml", "requirements.txt", "Pipfile", "setup.py" })
  if not root then
    return
  end

  local python = require("config.python")
  local interpreter = python.find_python(root)
  for _, name in ipairs({ ".venv", "venv" }) do
    local project_python = root .. "/" .. name .. "/bin/python"
    if vim.fn.executable(project_python) == 1 then
      interpreter = project_python
      break
    end
  end
  interpreter = interpreter or vim.fn.exepath("python3") or "python3"
  local env = python.term_env(root)
  if interpreter:find(root .. "/.venv/", 1, true) == 1 or interpreter:find(root .. "/venv/", 1, true) == 1 then
    env.VIRTUAL_ENV = vim.fn.fnamemodify(interpreter, ":h:h")
    env.PATH = env.VIRTUAL_ENV .. "/bin:" .. (env.PATH or "")
  end
  local current_file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype == "python" and current_file ~= "" and current_file:find(root .. "/", 1, true) == 1 then
    add_task(tasks, "Python: run current file", { interpreter, current_file }, root, env)
  end

  local manage_py = root .. "/manage.py"
  if exists(manage_py) then
    add_task(tasks, "Python: Django development server", { interpreter, manage_py, "runserver" }, root, env)
  else
    for _, name in ipairs({ "main.py", "app.py", "server.py" }) do
      local entrypoint = root .. "/" .. name
      if exists(entrypoint) then
        add_task(tasks, "Python: run " .. name, { interpreter, entrypoint }, root, env)
        break
      end
    end
  end

  local uv_lock = exists(root .. "/uv.lock")
  if uv_lock and vim.fn.executable("uv") == 1 then
    add_task(tasks, "Python: sync dependencies (uv sync)", { "uv", "sync" }, root, env)
  elseif exists(root .. "/requirements.txt") then
    local install = "python3 -m venv .venv && .venv/bin/python -m pip install -r requirements.txt"
    add_task(tasks, "Python: create .venv and install requirements", { "sh", "-lc", install }, root, env)
  end

  table.insert(tasks, {
    label = "Python: enter a server command…",
    cwd = root,
    env = env,
    prompt = true,
    default = uv_lock and "uv run uvicorn app.main:app --reload" or "uvicorn app.main:app --reload",
  })
end

local function add_compose_tasks(tasks)
  local root = vim.fs.root(0, { "compose.yaml", "compose.yml", "docker-compose.yaml", "docker-compose.yml" })
  if not root or vim.fn.executable("docker") ~= 1 then
    return
  end

  add_task(tasks, "Docker Compose: up", { "docker", "compose", "up" }, root)
  add_task(tasks, "Docker Compose: up detached", { "docker", "compose", "up", "-d" }, root)
  add_task(tasks, "Docker Compose: down", { "docker", "compose", "down" }, root)
  add_task(tasks, "Docker Compose: follow logs", { "docker", "compose", "logs", "-f" }, root)
end

local function makefile_targets(root)
  local path = root .. "/Makefile"
  if not exists(path) then
    return {}
  end

  local file = io.open(path, "r")
  if not file then
    return {}
  end

  local seen, targets = {}, {}
  for line in file:lines() do
    local target = line:match("^([%w%._-]+):")
    if target and target:sub(1, 1) ~= "." and not seen[target] then
      seen[target] = true
      table.insert(targets, target)
    end
  end
  file:close()
  table.sort(targets)
  return targets
end

local function add_general_tasks(tasks)
  local root = vim.fs.root(0, { "Makefile" })
  if not root then
    return
  end
  for _, target in ipairs(makefile_targets(root)) do
    add_task(tasks, "Make: " .. target, { "make", target }, root)
  end
end

local function run_task(task, command)
  vim.cmd("botright split")
  vim.cmd("resize 12")
  local job = vim.fn.jobstart(command or task.cmd, {
    term = true,
    cwd = task.cwd,
    env = task.env,
  })
  if job <= 0 then
    vim.notify("Could not start task: " .. task.label, vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

local function is_js_ft(ft)
  return ft:find("javascript", 1, true) or ft:find("typescript", 1, true)
end

function M.kind()
  local ft = vim.bo.filetype
  if ft == "go" then
    return "go"
  end
  if ft == "python" then
    return "python"
  end
  if is_js_ft(ft) and require("config.javascript").root() then
    return "js"
  end
  if require("config.go").root() then
    return "go"
  end
  if require("config.javascript").root() then
    return "js"
  end
  return "python"
end

function M.run()
  local kind = M.kind()
  if kind == "go" then
    require("config.go").pick_run()
  elseif kind == "js" then
    require("config.javascript").pick_script()
  else
    require("config.python").run_file()
  end
end

function M.project_tasks()
  local tasks = {}
  add_javascript_tasks(tasks)
  add_python_tasks(tasks)
  add_compose_tasks(tasks)
  add_general_tasks(tasks)

  local go = require("config.go")
  local go_root = go.root()
  if go_root then
    add_task(tasks, "Go: run current package", { "go", "run", "." }, go_root)
    add_task(tasks, "Go: test project", { "go", "test", "./..." }, go_root)
  end

  if #tasks == 0 then
    vim.notify("No project tasks found here", vim.log.levels.WARN)
    return
  end

  table.sort(tasks, function(a, b)
    return a.label < b.label
  end)
  vim.ui.select(tasks, {
    prompt = "Project task",
    format_item = function(task)
      return task.label
    end,
  }, function(task)
    if not task then
      return
    end
    if task.prompt then
      vim.ui.input({ prompt = "Python server command: ", default = task.default }, function(command)
        if command and command:match("%S") then
          run_task(task, command)
        end
      end)
      return
    end
    run_task(task)
  end)
end

function M.test_project()
  local kind = M.kind()
  if kind == "go" then
    require("config.go").test_project()
  elseif kind == "js" then
    require("config.javascript").test_project()
  else
    require("config.python").pytest_project()
  end
end

function M.test_file()
  local kind = M.kind()
  if kind == "go" then
    require("config.go").test_file()
  elseif kind == "js" then
    require("config.javascript").test_file()
  else
    require("config.python").pytest_file()
  end
end

return M
