local dap = require "dap"
dap.adapters.cppdbg = {
  name = "cppdbg",
  type = "executable",
  command = os.getenv "OpenDebugAD7_PATH",
}
dap.adapters.codelldb = {
  name = "codelldb",
  type = "executable",
  command = os.getenv "codelldb_PATH",
}
return {}
