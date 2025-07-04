-- Test runner script for persist-window.nvim
-- Run with: nvim --headless -c "luafile tests/run_tests.lua" -c "qa!"

-- Load test initialization
require("tests.init")

-- Check if plenary is available
local ok, plenary = pcall(require, "plenary.test_harness")

if not ok then
  print("Error: plenary.nvim is required for testing")
  print("Install with your package manager, e.g.:")
  print("  Lazy: { 'nvim-lua/plenary.nvim' }")
  print("  Packer: use 'nvim-lua/plenary.nvim'")
  vim.cmd("cquit 1")
end

-- Run tests
print("Running persist-window.nvim tests...")
print("=====================================")

local test_files = {
  "tests/window_spec.lua",
  "tests/state_spec.lua",
}

for _, test_file in ipairs(test_files) do
  print("Running: " .. test_file)
  plenary.test_directory(test_file)
end

print("=====================================")
print("Tests completed!")