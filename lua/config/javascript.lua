local M = {}

function M.root()
  return vim.fs.root(0, { "package.json" })
end

function M.package_manager(root)
  root = root or M.root()
  if not root then
    return "npm"
  end
  if vim.uv.fs_stat(root .. "/bun.lock") or vim.uv.fs_stat(root .. "/bun.lockb") then
    return "bun"
  end
  if vim.uv.fs_stat(root .. "/pnpm-lock.yaml") then
    return "pnpm"
  end
  if vim.uv.fs_stat(root .. "/yarn.lock") then
    return "yarn"
  end
  return "npm"
end

function M.read_package(root)
  root = root or M.root()
  if not root then
    return nil
  end
  local path = root .. "/package.json"
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local ok, pkg = pcall(vim.json.decode, file:read("*a"))
  file:close()
  if not ok then
    return nil
  end
  return pkg
end

function M.term_env(root)
  root = root or M.root() or vim.fn.getcwd()
  local env = vim.fn.environ()
  env.PATH = root .. "/node_modules/.bin:" .. (env.PATH or "")
  return env
end

local function run_in_split(cmd, root)
  vim.cmd("botright split")
  vim.cmd("resize 12")
  vim.fn.jobstart(cmd, {
    term = true,
    env = M.term_env(root),
    cwd = root,
  })
  vim.cmd("startinsert")
end

local function run_script_cmd(root, script)
  local pm = M.package_manager(root)
  if pm == "yarn" then
    return { "yarn", script }
  end
  if pm == "bun" then
    return { "bun", "run", script }
  end
  return { pm, "run", script }
end

function M.script_command(root, script)
  return run_script_cmd(root, script)
end

function M.pick_script()
  local root = M.root()
  if not root then
    vim.notify("No package.json found", vim.log.levels.WARN)
    return
  end
  local pkg = M.read_package(root)
  if not pkg or not pkg.scripts or vim.tbl_isempty(pkg.scripts) then
    vim.notify("No scripts in package.json", vim.log.levels.WARN)
    return
  end
  local names = vim.tbl_keys(pkg.scripts)
  table.sort(names)
  vim.ui.select(names, { prompt = "npm script" }, function(script)
    if not script then
      return
    end
    run_in_split(run_script_cmd(root, script), root)
  end)
end

function M.test_project()
  local root = M.root()
  if not root then
    vim.notify("No package.json found", vim.log.levels.WARN)
    return
  end
  local pkg = M.read_package(root) or {}
  local scripts = pkg.scripts or {}
  local script = scripts.test and "test" or scripts.vitest and "vitest" or scripts.jest and "jest"
  if not script then
    vim.notify("No test/vitest/jest script in package.json", vim.log.levels.WARN)
    return
  end
  run_in_split(run_script_cmd(root, script), root)
end

function M.test_file()
  local root = M.root()
  local file = vim.api.nvim_buf_get_name(0)
  if not root or file == "" then
    vim.notify("No package.json or file to test", vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  local vitest = root .. "/node_modules/.bin/vitest"
  local jest = root .. "/node_modules/.bin/jest"
  if vim.uv.fs_stat(vitest) then
    run_in_split({ vitest, "run", file }, root)
  elseif vim.uv.fs_stat(jest) then
    run_in_split({ jest, file }, root)
  else
    vim.notify("No vitest or jest in node_modules/.bin", vim.log.levels.WARN)
  end
end

function M.has_next(root)
  root = root or M.root()
  return root and vim.uv.fs_stat(root .. "/node_modules/next/dist/bin/next") ~= nil
end

function M.tsx_bin(root)
  root = root or M.root()
  if not root then
    return nil
  end
  local tsx = root .. "/node_modules/.bin/tsx"
  if vim.uv.fs_stat(tsx) then
    return tsx
  end
  return nil
end

return M
