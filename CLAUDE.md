# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Development Environment Setup
```bash
# Set up isolated development environment with dependencies
./scripts/setup-dev.sh

# Start development with isolated config (no global Neovim conflicts)
nvim -u .dev/init.lua

# Run all tests (41 tests)
./.dev/run-tests.sh

# Run individual test files
nvim -u .dev/init.lua -c "PlenaryBustedFile tests/window_spec.lua"
nvim -u .dev/init.lua -c "PlenaryBustedFile tests/state_spec.lua"
nvim -u .dev/init.lua -c "PlenaryBustedFile tests/integration_spec.lua"

# Interactive test session
nvim -u .dev/init.lua -c "lua require('plenary.test_harness').test_directory('tests/')"
```

### Manual Testing
```bash
# Start dev environment and create floating windows for testing
nvim -u .dev/init.lua -c ":help"
# Then test commands: :ListWindows, :PersistWindow, :ToggleWindow, :PersistWindowInfo
```

## Architecture Overview

### Core Concept
This plugin maintains **references** to actual floating window instances rather than recreating them. Windows are shown/hidden using `nvim_win_set_config()` to control visibility, achieving true persistence across tabs without content duplication.

**Key Design**: The plugin is fully **tab-agnostic** - all commands work across all tabs, not just the current tab. This means you can discover, persist, and manage floating windows from any tab regardless of where they were originally created.

### Module Structure
```
lua/persist-window/
├── init.lua      # Main entry point, command registration, user-facing functions
├── window.lua    # Low-level window detection and management (vim.api calls)
├── state.lua     # Global state management for persisted window references
└── ui.lua        # User interface, formatting, prompts, and messages
```

### Key Data Flow
1. **Detection**: `window.lua` finds floating windows using `nvim_tabpage_list_wins()` and config checks
2. **State**: `state.lua` stores window reference as `{ window_id, buffer_id, is_visible, metadata }`
3. **UI**: `ui.lua` formats displays and handles user selection prompts
4. **Commands**: `init.lua` orchestrates the flow between modules

### Critical Implementation Details

#### Window Reference vs Recreation
- Store actual `window_id` and `buffer_id` - never recreate
- Use `nvim_win_set_config()` to move windows off-screen (hide) or reposition (show)
- Preserve all buffer content and window state automatically

#### State Management Pattern
```lua
-- Single global state in state.lua
M.persisted_window = {
  window_id = 1001,     -- Actual window ID
  buffer_id = 42,       -- Actual buffer ID
  is_visible = true,    -- Current visibility
  last_tab = 2,         -- Last tab where visible
  config = {},          -- Original window config
  metadata = { created_at = "" }
}
```

#### Window Detection Logic
```lua
-- Core floating window detection in window.lua (tab-agnostic)
for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then  -- floating window check
      table.insert(floating_wins, {
        window_id = win,
        tab_id = tab,
        config = config
      })
    end
  end
end
```

### Testing Architecture

#### Test Framework
- Uses Plenary.nvim for comprehensive testing
- Isolated test environment via `.dev/init.lua` (no global conflicts)
- 41 passing tests covering all core functionality

#### Test Structure
- `tests/window_spec.lua` - Window detection and management functions
- `tests/state_spec.lua` - State management and persistence logic
- `tests/integration_spec.lua` - End-to-end command workflows

#### Key Testing Patterns
- Mock floating windows using `vim.api.nvim_open_win()`
- Test window validity with `vim.api.nvim_win_is_valid()`
- Verify state transitions and error handling
- Integration tests for all user commands

### Development Guidelines

#### Command Implementation Status
- ✅ `:ListWindows` - Fully implemented and tested (tab-agnostic)
- ✅ `:PersistWindow` - Fully implemented and tested (tab-agnostic)
- ✅ `:ToggleWindow` - Fully implemented with cross-tab recreation
- ✅ `:PersistWindowInfo` - Fully implemented and tested
- ✅ Auto-hide on tab switch - Fully implemented and tested

#### Type Annotations
All functions use LuaCATS type annotations:
```lua
---@param win_id number Window ID to validate
---@return boolean valid Whether window exists and is valid
function M.validate_window(win_id)
```

#### Error Handling Pattern
- Validate inputs before operations
- Graceful degradation with user-friendly messages
- State cleanup on invalid window references
- Consistent error messaging via `ui.lua`

### Key Dependencies
- **Plenary.nvim** - Required for testing framework
- **Neovim 0.8.0+** - For Lua API compatibility

### Implementation Status
All core functionality has been completed and tested:
1. ✅ Complete window show/hide logic in `:ToggleWindow`
2. ✅ Cross-tab window recreation and positioning
3. ✅ Window validation and cleanup automations
4. ✅ Enhanced error handling for edge cases
5. ✅ Tab-agnostic behavior for all commands
6. ✅ Auto-hide functionality on tab switches
7. ✅ Always-on-top mode to keep windows visible across tabs

The plugin is now feature-complete and ready for production use.

### Always On Top Feature
The plugin supports an "always on top" mode that keeps persisted windows visible when switching tabs:
- Configure globally via `setup({ always_on_top = true })`
- Toggle per-window with `:PersistWindowAlwaysOnTop`
- When enabled, windows maintain position and visibility across all tabs
- When disabled, windows auto-hide on tab switch (original behavior)

## CI/CD

### GitHub Actions Workflows
The project uses GitHub Actions for continuous integration and deployment:

#### Continuous Integration (`.github/workflows/ci.yml`)
- Tests against multiple Neovim versions: 0.8.0, 0.9.0, stable, nightly
- Runs all 41 tests using Plenary.nvim
- Validates code formatting with StyLua
- Performs static analysis with luacheck

#### Code Quality (`.github/workflows/quality.yml`)
- Enforces code formatting standards (StyLua)
- Runs luacheck static analysis
- Validates documentation completeness

#### Automated Releases (`.github/workflows/release.yml`)
- Uses semantic-release for automated versioning
- Generates changelogs following Keep a Changelog format
- Creates GitHub releases automatically
- Triggered on pushes to main branch after CI passes

### Commit Convention
The project follows conventional commits for semantic versioning:
- `feat:` New features (bumps minor version)
- `fix:` Bug fixes (bumps patch version)
- `BREAKING CHANGE:` Breaking changes (bumps major version)
- `docs:`, `chore:`, `test:`, etc. (no version bump)
