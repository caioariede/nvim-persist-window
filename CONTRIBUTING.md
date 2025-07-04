# Contributing to persist-window.nvim

Thank you for your interest in contributing to persist-window.nvim! This document provides guidelines and instructions for contributors.

## Development Setup

### Prerequisites

- Neovim 0.8.0+ (for Lua API compatibility)
- Git
- Bash (for setup scripts)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/caioariede/nvim-persist-window.git
   cd nvim-persist-window
   ```

2. **Set up development environment**
   ```bash
   ./scripts/setup-dev.sh
   ```

3. **Start development**
   ```bash
   nvim -u .dev/init.lua
   ```

4. **Run tests**
   ```bash
   ./.dev/run-tests.sh
   ```

### Development Environment Details

The setup script creates a `.dev/` directory with:

- **plenary.nvim** - Testing framework dependency
- **init.lua** - Development Neovim configuration
- **run-tests.sh** - Automated test runner

This approach ensures:
- ✅ No global Neovim configuration conflicts
- ✅ Isolated development dependencies
- ✅ Consistent testing environment
- ✅ Easy contributor onboarding

## Testing

### Running Tests

```bash
# All tests
./.dev/run-tests.sh

# Interactive testing
nvim -u .dev/init.lua -c "lua require('plenary.test_harness').test_directory('tests/')"

# Individual test files
nvim -u .dev/init.lua -c "PlenaryBustedFile tests/window_spec.lua"
```

### Writing Tests

We use [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing. Test files are located in `tests/`:

- `window_spec.lua` - Window management functions
- `state_spec.lua` - State management functions
- `integration_spec.lua` - Command integration tests

Example test structure:
```lua
describe("my_module", function()
  before_each(function()
    -- Setup before each test
  end)

  it("should do something", function()
    assert.are.equal(expected, actual)
  end)
end)
```

### Test Coverage Requirements

All new features must include:
- ✅ Unit tests for core functionality
- ✅ Integration tests for user-facing commands
- ✅ Error handling tests
- ✅ Edge case coverage

## Code Standards

### Lua Code Style

We use [StyLua](https://github.com/JohnnyMorganz/StyLua) for consistent formatting:

```bash
# Install StyLua
cargo install stylua

# Format code
stylua lua/ tests/
```

### LuaCATS Type Annotations

All functions must include LuaCATS type annotations:

```lua
---@class MyClass
---@field property string

---Function description
---@param param string Parameter description
---@return boolean success Whether operation succeeded
function my_function(param)
  -- implementation
end
```

### Static Analysis

We use [Luacheck](https://github.com/mpeterv/luacheck) for static analysis:

```bash
# Install Luacheck
luarocks install luacheck

# Check code
luacheck lua/ tests/
```

## Development Workflow

### 1. Feature Development

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Write tests first (TDD approach)
3. Implement the feature
4. Ensure all tests pass
5. Update documentation

### 2. Bug Fixes

1. Create a bug fix branch: `git checkout -b fix/issue-description`
2. Add a test that reproduces the bug
3. Fix the bug
4. Ensure the test passes
5. Verify no regressions

### 3. Pull Request Process

1. Ensure all tests pass: `./.dev/run-tests.sh`
2. Format code: `stylua lua/ tests/`
3. Check static analysis: `luacheck lua/ tests/`
4. Update CHANGELOG.md
5. Submit pull request with clear description

## Architecture Guidelines

### Module Structure

```
lua/persist-window/
├── init.lua           # Main entry point and commands
├── window.lua         # Window detection and management
├── state.lua          # State management
├── ui.lua            # User interface functions
└── config.lua        # Configuration handling (future)
```

### Coding Principles

- **Single Responsibility** - Each module has one clear purpose
- **Dependency Injection** - Use function parameters over global state
- **Error Handling** - Graceful degradation, helpful error messages
- **Documentation** - Self-documenting code with clear naming

### API Design

- **Consistent Naming** - Use clear, descriptive function names
- **Return Values** - Return success/failure indicators consistently
- **Parameters** - Use optional parameters with sensible defaults
- **Error Messages** - Provide actionable error messages to users

## Manual Testing

### Test Scenarios

1. **Basic ListWindows (Tab-Agnostic)**
   ```vim
   " Create a floating help window
   :lua vim.cmd('help'); vim.api.nvim_win_set_config(0, {relative='editor', width=80, height=20, row=5, col=10})
   :ListWindows  " Should show the floating help window with [Tab 1] indicator
   ```

2. **Cross-Tab Window Detection**
   ```vim
   " Create floating help window in tab 1
   :lua vim.cmd('help'); vim.api.nvim_win_set_config(0, {relative='editor', width=80, height=20, row=5, col=10})
   :tabnew
   " Create floating terminal in tab 2
   :lua vim.cmd('terminal'); vim.api.nvim_win_set_config(0, {relative='editor', width=60, height=15, row=10, col=20})
   :ListWindows  " Should show both floating windows from different tabs
   ```

3. **No Floating Windows**
   ```vim
   :ListWindows  " Should show "No floating windows found in any tab"
   ```

4. **Cross-Tab Window Persistence**
   ```vim
   " Create floating help window
   :lua vim.cmd('help'); vim.api.nvim_win_set_config(0, {relative='editor', width=80, height=20, row=5, col=10})
   :tabnew
   :PersistWindow 1001  " Persist window from another tab (use actual window ID)
   :ToggleWindow        " Should show/hide the help window in current tab
   ```

5. **Auto-Hide on Tab Switch**
   ```vim
   " Create floating help window
   :lua vim.cmd('help'); vim.api.nvim_win_set_config(0, {relative='editor', width=80, height=20, row=5, col=10})
   :PersistWindow
   :ToggleWindow  " Show window
   :tabnew        " Window should auto-hide
   :ToggleWindow  " Should show window in new tab
   ```

## Documentation

### Code Documentation

- Use LuaCATS annotations for all public functions
- Include usage examples in docstrings
- Document complex algorithms with inline comments

### User Documentation

- Update help documentation in `doc/persist-window.txt`
- Include examples in README.md
- Maintain CHANGELOG.md for all changes

## Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** - Breaking changes
- **MINOR** - New features (backward compatible)
- **PATCH** - Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number bumped
- [ ] Git tag created
- [ ] Release notes written

## Getting Help

- **Discussions** - Use GitHub Discussions for questions
- **Issues** - Report bugs via GitHub Issues
- **Code Review** - Request reviews on pull requests
- **Documentation** - Check existing docs and tests for examples

## Code of Conduct

Be respectful, constructive, and collaborative. We're all here to build something useful together.

---

Thank you for contributing to persist-window.nvim! 🚀
