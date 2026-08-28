local M = {}

function M.root()
  return vim.fs.root(0, { "go.mod" })
end

function M.package_dir()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    return vim.fn.fnamemodify(file, ":h")
  end
  return vim.fn.getcwd()
end

local function run_in_split(cmd, cwd)
  vim.cmd("botright split")
  vim.cmd("resize 12")
  vim.fn.jobstart(cmd, {
    term = true,
    cwd = cwd,
  })
  vim.cmd("startinsert")
end

local function makefile_targets(root)
  local path = root .. "/Makefile"
  if not vim.uv.fs_stat(path) then
    return {}
  end
  local file = io.open(path, "r")
  if not file then
    return {}
  end
  local seen = {}
  local targets = {}
  for line in file:lines() do
    local target = line:match("^([%w%._-]+):")
    if target and not target:find("^%.") and not seen[target] then
      seen[target] = true
      table.insert(targets, target)
    end
  end
  file:close()
  table.sort(targets)
  return targets
end

function M.pick_run()
  local root = M.root()
  if not root then
    vim.notify("No go.mod found", vim.log.levels.WARN)
    return
  end
  local pkg = M.package_dir()
  local items = {
    { label = "go run .", cmd = { "go", "run", "." }, cwd = pkg },
    { label = "go test .", cmd = { "go", "test", "." }, cwd = pkg },
    { label = "go test ./...", cmd = { "go", "test", "./..." }, cwd = root },
  }
  for _, target in ipairs(makefile_targets(root)) do
    table.insert(items, {
      label = "make " .. target,
      cmd = { "make", target },
      cwd = root,
    })
  end
  vim.ui.select(items, {
    prompt = "Go",
    format_item = function(item)
      return item.label
    end,
  }, function(item)
    if not item then
      return
    end
    run_in_split(item.cmd, item.cwd)
  end)
end

function M.test_project()
  local root = M.root()
  if not root then
    vim.notify("No go.mod found", vim.log.levels.WARN)
    return
  end
  run_in_split({ "go", "test", "./..." }, root)
end

function M.test_file()
  local root = M.root()
  if not root then
    vim.notify("No go.mod found", vim.log.levels.WARN)
    return
  end
  run_in_split({ "go", "test", "." }, M.package_dir())
end

return M
