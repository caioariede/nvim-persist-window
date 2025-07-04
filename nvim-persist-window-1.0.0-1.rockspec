rockspec_format = "3.0"
package = "nvim-persist-window"
version = "1.0.0-1"

source = {
   url = "git+https://github.com/caioariede/nvim-persist-window.git",
   tag = "v1.0.0"
}

description = {
   summary = "Persistent floating windows for Neovim",
   detailed = [[
      This plugin makes floating windows persistent across tabs in Neovim.
      Instead of recreating window state, it maintains references to actual
      floating window instances and controls their visibility using Neovim's
      native API. Features include tab-independent window management,
      always-on-top mode, and true window persistence without content duplication.
   ]],
   homepage = "https://github.com/caioariede/nvim-persist-window",
   license = "MIT"
}

dependencies = {
   "lua >= 5.1"
}

build = {
   type = "builtin",
   modules = {
      ["persist-window"] = "lua/persist-window/init.lua",
      ["persist-window.window"] = "lua/persist-window/window.lua",
      ["persist-window.state"] = "lua/persist-window/state.lua",
      ["persist-window.ui"] = "lua/persist-window/ui.lua"
   },
   copy_directories = {
      "doc",
      "plugin"
   }
}

test_dependencies = {
   "plenary.nvim"
}

test = {
   type = "command",
   command = "nvim -u tests/init.lua -c 'lua require(\"plenary.test_harness\").test_directory(\"tests/\")'"
}
