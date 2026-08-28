local M = {}

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
