#!/bin/bash

# Development environment setup script for persist-window.nvim
# This script sets up a minimal Neovim environment with required dependencies

set -e

echo "Setting up persist-window.nvim development environment..."

# Create temporary directory for development dependencies
DEV_DIR="$(pwd)/.dev"
DEPS_DIR="$DEV_DIR/deps"

mkdir -p "$DEPS_DIR"

echo "Installing development dependencies..."

# Clone plenary.nvim if not already present
if [ ! -d "$DEPS_DIR/plenary.nvim" ]; then
    echo "Cloning plenary.nvim..."
    git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git "$DEPS_DIR/plenary.nvim"
else
    echo "plenary.nvim already installed"
fi

# Create development init.lua
cat > "$DEV_DIR/init.lua" << 'EOF'
-- Development environment initialization
-- This file sets up the runtime path for testing

-- Add dependencies to runtime path
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/.dev/deps/plenary.nvim")

-- Add current project to runtime path
vim.opt.rtp:prepend(vim.fn.getcwd())

-- Load the plugin
require('persist-window').setup()

print("persist-window.nvim development environment loaded!")
print("Available commands: :ListWindows, :PersistWindow, :ToggleWindow, :PersistWindowInfo")
print("Run tests with: :lua require('plenary.test_harness').test_directory('tests/')")
EOF

# Create test runner script
cat > "$DEV_DIR/run-tests.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/.."
nvim --headless --noplugin -u .dev/init.lua -c "lua require('plenary.test_harness').test_directory('tests/')" -c "qa!"
EOF

chmod +x "$DEV_DIR/run-tests.sh"

# Create development README
cat > "$DEV_DIR/README.md" << 'EOF'
# Development Environment

This directory contains the development setup for persist-window.nvim.

## Files

- `init.lua` - Development Neovim configuration
- `deps/` - Development dependencies (plenary.nvim)
- `run-tests.sh` - Test runner script

## Usage

### Start development environment
```bash
nvim -u .dev/init.lua
```

### Run tests
```bash
./.dev/run-tests.sh
```

### Manual testing
```bash
nvim -u .dev/init.lua -c ":help"
# Then create a floating window and test commands
```
EOF

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "Usage:"
echo "  Start dev environment: nvim -u .dev/init.lua"
echo "  Run tests:             ./.dev/run-tests.sh"
echo "  Manual testing:        nvim -u .dev/init.lua -c ':help'"
echo ""
echo "The .dev/ directory contains all development dependencies."
echo "Add .dev/ to your .gitignore if you haven't already."