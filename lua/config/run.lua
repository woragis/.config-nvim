local M = {}

function M.is_js()
  return require("config.javascript").root() ~= nil
end

function M.run()
  if M.is_js() then
    require("config.javascript").pick_script()
  else
    require("config.python").run_file()
  end
end

function M.test_project()
  if M.is_js() then
    require("config.javascript").test_project()
  else
    require("config.python").pytest_project()
  end
end

function M.test_file()
  if M.is_js() then
    require("config.javascript").test_file()
  else
    require("config.python").pytest_file()
  end
end

return M
