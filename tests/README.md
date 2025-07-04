# Testing persist-window.nvim

## Prerequisites

This plugin uses [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing. Make sure you have it installed:

```lua
-- Lazy.nvim
{ 'nvim-lua/plenary.nvim' }

-- Packer
use 'nvim-lua/plenary.nvim'
```

## Running Tests

### All Tests
```bash
nvim --headless -c "luafile tests/run_tests.lua" -c "qa!"
```

### Individual Test Files
```bash
# Window module tests
nvim --headless -c "PlenaryBustedDirectory tests/window_spec.lua" -c "qa!"

# State module tests  
nvim --headless -c "PlenaryBustedDirectory tests/state_spec.lua" -c "qa!"

# Integration tests
nvim --headless -c "PlenaryBustedDirectory tests/integration_spec.lua" -c "qa!"
```

### Interactive Testing
```vim
:luafile tests/init.lua
:PlenaryBustedDirectory tests/
```

## Test Structure

- `tests/init.lua` - Test environment setup
- `tests/window_spec.lua` - Unit tests for window management functions
- `tests/state_spec.lua` - Unit tests for state management functions  
- `tests/integration_spec.lua` - Integration tests for commands
- `tests/run_tests.lua` - Test runner script

## Writing Tests

Tests use the [busted](https://olivinelabs.com/busted/) testing framework via plenary.nvim. 

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