-- Luacheck configuration for nvim-persist-window
-- https://luacheck.readthedocs.io/en/stable/config.html

-- Global vim APIs that are available in Neovim
globals = {
  "vim",
}

-- Standard library
std = "lua51"

-- Ignore specific warnings
ignore = {
  "212/_.*",     -- Unused argument, for variables with "_" prefix
  "213",         -- Unused loop variable
  "631",         -- Line is too long
}

-- Files to exclude from checking
exclude_files = {
  ".dev/",
  "tests/",
}

-- Maximum line length
max_line_length = 120

-- Maximum cyclomatic complexity
max_cyclomatic_complexity = 10
