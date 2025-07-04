# persist-window.nvim

Keeps floating windows available across tabs in Neovim.

When you switch tabs, floating windows (terminals, help, etc.) normally disappear. This plugin saves them so you can toggle them back instantly from any tab.

## Features

- Keep floating windows across tab switches
- Toggle windows on/off from any tab  
- Always-on-top mode to keep windows visible
- Works with any floating window (terminals, help, plugins)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'caioariede/nvim-persist-window',
  config = function()
    require('persist-window').setup({
      always_on_top = false,  -- Keep windows visible across tab switches
    })
  end
}
```

*Other package managers (packer, vim-plug) are also supported.*

## Commands

| Command | Description |
|---------|-------------|
| `:ListWindows` | Show available floating windows |
| `:PersistWindow [ID]` | Save a floating window for later use |
| `:ToggleWindow` | Show/hide the saved window |
| `:PersistWindowInfo` | Show information about saved window |
| `:PersistWindowAlwaysOnTop [on/off]` | Keep window visible across tab switches |

## 🎯 Usage Workflow

1. **Open a floating window** (terminal, help, custom plugin, etc.)
2. **List windows** (optional): `:ListWindows` 
3. **Persist window**: `:PersistWindow`
4. **Switch to different tab**
5. **Toggle window**: `:ToggleWindow` to show the persisted window
6. **Toggle again**: `:ToggleWindow` to hide it

## 📖 Examples

### Basic Usage

```vim
" 1. First, create a floating window (using any method you prefer)
"    For example, using a plugin like telescope, or manually:
:lua vim.cmd('help'); vim.api.nvim_win_set_config(0, {relative='editor', width=80, height=20, row=5, col=10})

" 2. Persist the floating window
:PersistWindow

" 3. Switch to another tab
:tabnew

" 4. Show the persisted window in the new tab
:ToggleWindow
```

### Multiple Floating Windows

```vim
" Open multiple floating windows (example assumes you have plugins that create them)
" Or create them manually - this is just to show the concept:
" (In practice, floating windows are usually created by plugins like telescope, nvim-tree, etc.)

" List all floating windows that exist
:ListWindows
" Output:
" Floating Windows (All Tabs):
" 1. Window 1001 - [No Name] (10x20 at row 5, col 10) [Tab 1]
" 2. Window 1002 - "help.txt" (15x30 at row 2, col 25) [Tab 2]
" 
" Use :PersistWindow [ID] to persist a specific window
" Note: HIDDEN windows are persisted but currently off-screen

" Persist specific window
:PersistWindow 1002
```

### Claude Code Integration

Set up [Claude Code](https://github.com/greggh/claude-code.nvim) to open in a persistent floating window:

```lua
-- Configure Claude Code to use floating window
require('claude-code').setup({
  window = {
    position = "float",
    float = {
      width = "50%",
      height = "98%",
      row = "0%",
      col = "49%"
    }
  }
})
```

```vim
" Function to open Claude Code and make it persistent
function! OpenClaudeWithPersist()
    silent execute 'ClaudeCode'
    sleep 300m
    silent execute 'PersistWindow'
    silent execute 'PersistWindowAlwaysOnTop on'
endfunction

" Map to leader+c
nnoremap <leader>c :call OpenClaudeWithPersist()<CR>
```

Now `<leader>c` opens Claude Code in a floating window that persists across all tabs.

### Always On Top Mode

Keep floating windows visible across all tab switches:

```vim
" Open a floating window
:help
" Persist it
:PersistWindow
" Enable always-on-top mode
:PersistWindowAlwaysOnTop on
" Now the window stays visible when switching tabs!
:tabnew
" The floating window is still there

" Disable always-on-top
:PersistWindowAlwaysOnTop off
" Or toggle it
:PersistWindowAlwaysOnTop
```

You can also enable always-on-top by default in your configuration:

```lua
require('persist-window').setup({
  always_on_top = true,  -- All persisted windows will be always-on-top by default
})
```

MIT License - see [LICENSE](LICENSE) file for details.

---

## Development

### Quick Start

```bash
# Clone repository
git clone https://github.com/caioariede/nvim-persist-window.git
cd nvim-persist-window

# Set up development environment
./scripts/setup-dev.sh

# Run tests
./.dev/run-tests.sh

# Start development
nvim -u .dev/init.lua
```

### Testing

```bash
# All tests
./.dev/run-tests.sh

# Individual test files  
nvim -u .dev/init.lua -c "PlenaryBustedFile tests/window_spec.lua"
```

**Test Results:** 41 tests passing with 100% core functionality coverage

### Architecture

Instead of capturing and recreating window state, we:

1. **Persist Reference** - Store actual window and buffer IDs
2. **Control Visibility** - Use `nvim_win_hide()` and `nvim_win_set_config()` 
3. **Tab Independence** - Detach from tab-local behavior

### Project Structure

```
persist-window.nvim/
├── lua/persist-window/
│   ├── init.lua         # Main entry point and commands
│   ├── window.lua       # Window detection and management  
│   ├── state.lua        # State management
│   └── ui.lua          # User interface functions
├── tests/               # Comprehensive test suite
└── scripts/             # Development tools
```

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, testing guidelines, and pull request process.

**Requirements:** Neovim 0.8.0+, Git, Bash

### CI/CD

This project uses GitHub Actions for continuous integration and automated releases:

[![CI](https://github.com/caioariede/nvim-persist-window/actions/workflows/ci.yml/badge.svg)](https://github.com/caioariede/nvim-persist-window/actions/workflows/ci.yml)
[![Code Quality](https://github.com/caioariede/nvim-persist-window/actions/workflows/quality.yml/badge.svg)](https://github.com/caioariede/nvim-persist-window/actions/workflows/quality.yml)

- **Automated Testing**: Tests run against multiple Neovim versions (0.8.0+)
- **Code Quality**: Enforced formatting with StyLua and linting with luacheck
- **Semantic Releases**: Automated version bumping and changelog generation
- **Conventional Commits**: Use `feat:`, `fix:`, `docs:`, etc. for automatic versioning
