-- Integration tests for persist-window.nvim commands
local persist_float = require("persist-window")

describe("persist-window integration", function()
  before_each(function()
    -- Setup the plugin
    persist_float.setup({})
    -- Load plugin commands (simulate what plugin/persist-window.lua does)
    dofile(vim.fn.getcwd() .. "/plugin/persist-window.lua")
  end)

  describe("ListWindows command", function()
    it("should be registered as a user command", function()
      -- Check if the command exists
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.ListWindows)
      assert.are.equal("List all floating windows in the current tab", commands.ListWindows.definition)
    end)

    it("should handle no floating windows gracefully", function()
      -- Mock empty floating windows across all tabs
      local original_nvim_list_tabpages = vim.api.nvim_list_tabpages
      local original_nvim_tabpage_list_wins = vim.api.nvim_tabpage_list_wins
      vim.api.nvim_list_tabpages = function()
        return { 1 }
      end
      vim.api.nvim_tabpage_list_wins = function()
        return {}
      end

      -- This should not error
      assert.has_no.errors(function()
        persist_float.list_windows()
      end)

      vim.api.nvim_list_tabpages = original_nvim_list_tabpages
      vim.api.nvim_tabpage_list_wins = original_nvim_tabpage_list_wins
    end)
  end)

  describe("PersistWindow command", function()
    it("should be registered as a user command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PersistWindow)
      assert.are.equal("Persist a floating window", commands.PersistWindow.definition)
    end)

    it("should handle no floating windows gracefully", function()
      local original_nvim_list_tabpages = vim.api.nvim_list_tabpages
      local original_nvim_tabpage_list_wins = vim.api.nvim_tabpage_list_wins
      vim.api.nvim_list_tabpages = function()
        return { 1 }
      end
      vim.api.nvim_tabpage_list_wins = function()
        return {}
      end

      assert.has_no.errors(function()
        persist_float.persist_window("")
      end)

      vim.api.nvim_list_tabpages = original_nvim_list_tabpages
      vim.api.nvim_tabpage_list_wins = original_nvim_tabpage_list_wins
    end)
  end)

  describe("ToggleWindow command", function()
    it("should be registered as a user command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.ToggleWindow)
      assert.are.equal("Toggle the persisted floating window", commands.ToggleWindow.definition)
    end)

    it("should handle no persisted window gracefully", function()
      assert.has_no.errors(function()
        persist_float.toggle_window()
      end)
    end)
  end)

  describe("PersistWindowInfo command", function()
    it("should be registered as a user command", function()
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.PersistWindowInfo)
      assert.are.equal("Show information about the persisted window", commands.PersistWindowInfo.definition)
    end)

    it("should handle no persisted window gracefully", function()
      assert.has_no.errors(function()
        persist_float.show_window_info()
      end)
    end)
  end)

  describe("handle_tab_switch", function()
    it("should auto-hide visible persisted window on tab switch", function()
      local state = require("persist-window.state")
      local window = require("persist-window.window")

      -- Mock a persisted window that's visible
      state.persisted_window = {
        window_id = 1001,
        buffer_id = 42,
        is_visible = true,
        last_tab = 1,
        config = { relative = "editor", row = 5, col = 10 },
        metadata = { created_at = "2024-01-01", persistent_id = "test" },
      }

      -- Mock window functions
      local original_is_window_valid = state.is_window_valid
      local original_is_window_visible = window.is_window_visible
      local original_hide_window = window.hide_window
      local hide_called = false

      state.is_window_valid = function()
        return true
      end
      window.is_window_visible = function()
        return true
      end
      window.hide_window = function(win_id)
        hide_called = true
        assert.are.equal(1001, win_id)
        return true
      end

      -- Call handle_tab_switch
      persist_float.handle_tab_switch()

      -- Verify window was hidden and state updated
      assert.is_true(hide_called)
      assert.is_false(state.persisted_window.is_visible)

      -- Restore original functions
      state.is_window_valid = original_is_window_valid
      window.is_window_visible = original_is_window_visible
      window.hide_window = original_hide_window

      -- Clean up state
      state.clear_persisted_window()
    end)

    it("should not hide already hidden windows", function()
      local state = require("persist-window.state")
      local window = require("persist-window.window")

      -- Mock a persisted window that's already hidden
      state.persisted_window = {
        window_id = 1001,
        buffer_id = 42,
        is_visible = false, -- Already hidden
        last_tab = 1,
        config = { relative = "editor", row = 5, col = 10 },
        metadata = { created_at = "2024-01-01", persistent_id = "test" },
      }

      -- Mock window functions
      local hide_called = false
      local original_hide_window = window.hide_window
      window.hide_window = function()
        hide_called = true
        return true
      end

      -- Call handle_tab_switch
      persist_float.handle_tab_switch()

      -- Verify hide was not called since window is already hidden
      assert.is_false(hide_called)

      -- Restore and clean up
      window.hide_window = original_hide_window
      state.clear_persisted_window()
    end)
  end)
end)
