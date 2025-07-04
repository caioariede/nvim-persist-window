-- Plugin initialization file
-- This file is automatically loaded by Neovim when the plugin is installed

-- Prevent loading the plugin multiple times
if vim.g.loaded_persist_window then
  return
end
vim.g.loaded_persist_window = 1

-- Get the plugin module
local persist_window = require("persist-window")

-- Create user commands that are always available
vim.api.nvim_create_user_command("ListWindows", function()
  persist_window.list_windows()
end, {
  desc = "List all floating windows in the current tab",
})

vim.api.nvim_create_user_command("PersistWindow", function(args)
  persist_window.persist_window(args.args)
end, {
  nargs = "?",
  desc = "Persist a floating window",
})

vim.api.nvim_create_user_command("ToggleWindow", function()
  persist_window.toggle_window()
end, {
  desc = "Toggle the persisted floating window",
})

vim.api.nvim_create_user_command("PersistWindowInfo", function()
  persist_window.show_window_info()
end, {
  desc = "Show information about the persisted window",
})

vim.api.nvim_create_user_command("PersistWindowAlwaysOnTop", function(args)
  persist_window.toggle_always_on_top(args.args)
end, {
  nargs = "?",
  desc = "Toggle or set always-on-top mode for persisted window",
})

-- Set up autocmd for tab switching with default behavior
vim.api.nvim_create_autocmd("TabEnter", {
  group = vim.api.nvim_create_augroup("PersistWindowTabSwitch", { clear = true }),
  callback = function()
    persist_window.handle_tab_switch()
  end,
  desc = "Auto-hide persisted windows on tab switch",
})
