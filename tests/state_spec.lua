-- Unit tests for state.lua module
local state = require("persist-window.state")

describe("persist-window.state", function()
  -- Reset state before each test
  before_each(function()
    state.clear_persisted_window()
  end)

  describe("set_persisted_window", function()
    it("should return false for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function()
        return false
      end

      local result = state.set_persisted_window(9999)
      assert.is_false(result)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)

    it("should set persisted window for valid window", function()
      local mock_config = { relative = "editor", width = 80, height = 24 }
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage

      vim.api.nvim_win_is_valid = function()
        return true
      end
      vim.api.nvim_win_get_buf = function()
        return 42
      end
      vim.api.nvim_win_get_config = function()
        return mock_config
      end
      vim.api.nvim_get_current_tabpage = function()
        return 2
      end

      local result = state.set_persisted_window(1001)
      assert.is_true(result)

      local persisted = state.get_persisted_window()
      assert.is_not_nil(persisted)
      assert.are.equal(1001, persisted.window_id)
      assert.are.equal(42, persisted.buffer_id)
      assert.is_true(persisted.is_visible)
      assert.are.equal(2, persisted.last_tab)
      assert.are.same(mock_config, persisted.config)
      assert.is_not_nil(persisted.metadata)
      assert.is_not_nil(persisted.metadata.created_at)
      assert.is_not_nil(persisted.metadata.persistent_id)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_win_get_config = original_nvim_win_get_config
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
    end)
  end)

  describe("get_persisted_window", function()
    it("should return nil when no window is persisted", function()
      local result = state.get_persisted_window()
      assert.is_nil(result)
    end)

    it("should return persisted window state", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage

      vim.api.nvim_win_is_valid = function()
        return true
      end
      vim.api.nvim_win_get_buf = function()
        return 42
      end
      vim.api.nvim_win_get_config = function()
        return { relative = "editor" }
      end
      vim.api.nvim_get_current_tabpage = function()
        return 1
      end

      state.set_persisted_window(1001)
      local result = state.get_persisted_window()

      assert.is_not_nil(result)
      assert.are.equal(1001, result.window_id)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_win_get_config = original_nvim_win_get_config
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
    end)
  end)

  describe("clear_persisted_window", function()
    it("should clear persisted window state", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage

      vim.api.nvim_win_is_valid = function()
        return true
      end
      vim.api.nvim_win_get_buf = function()
        return 42
      end
      vim.api.nvim_win_get_config = function()
        return { relative = "editor" }
      end
      vim.api.nvim_get_current_tabpage = function()
        return 1
      end

      -- First set a window
      state.set_persisted_window(1001)
      assert.is_not_nil(state.get_persisted_window())

      -- Then clear it
      state.clear_persisted_window()
      assert.is_nil(state.get_persisted_window())

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_win_get_config = original_nvim_win_get_config
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
    end)
  end)

  describe("is_window_valid", function()
    it("should return false for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function()
        return false
      end

      local result = state.is_window_valid(9999)
      assert.is_false(result)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)

    it("should return true for valid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function()
        return true
      end

      local result = state.is_window_valid(1001)
      assert.is_true(result)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)
  end)

  describe("update_visibility", function()
    it("should update visibility when window is persisted", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage

      vim.api.nvim_win_is_valid = function()
        return true
      end
      vim.api.nvim_win_get_buf = function()
        return 42
      end
      vim.api.nvim_win_get_config = function()
        return { relative = "editor" }
      end
      vim.api.nvim_get_current_tabpage = function()
        return 1
      end

      state.set_persisted_window(1001)
      assert.is_true(state.get_persisted_window().is_visible)

      state.update_visibility(false)
      assert.is_false(state.get_persisted_window().is_visible)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_win_get_config = original_nvim_win_get_config
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
    end)

    it("should do nothing when no window is persisted", function()
      state.update_visibility(false)
      assert.is_nil(state.get_persisted_window())
    end)
  end)

  describe("update_last_tab", function()
    it("should update last_tab when window is persisted", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage

      vim.api.nvim_win_is_valid = function()
        return true
      end
      vim.api.nvim_win_get_buf = function()
        return 42
      end
      vim.api.nvim_win_get_config = function()
        return { relative = "editor" }
      end
      vim.api.nvim_get_current_tabpage = function()
        return 1
      end

      state.set_persisted_window(1001)
      assert.are.equal(1, state.get_persisted_window().last_tab)

      state.update_last_tab(3)
      assert.are.equal(3, state.get_persisted_window().last_tab)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_win_get_config = original_nvim_win_get_config
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
    end)
  end)

  describe("get_persisted_window_id", function()
    it("should return nil when no window is persisted", function()
      local result = state.get_persisted_window_id()
      assert.is_nil(result)
    end)

    it("should return window ID when window is persisted", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage

      vim.api.nvim_win_is_valid = function()
        return true
      end
      vim.api.nvim_win_get_buf = function()
        return 42
      end
      vim.api.nvim_win_get_config = function()
        return { relative = "editor" }
      end
      vim.api.nvim_get_current_tabpage = function()
        return 1
      end

      state.set_persisted_window(1001)
      local result = state.get_persisted_window_id()
      assert.are.equal(1001, result)

      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_win_get_config = original_nvim_win_get_config
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
    end)
  end)
end)
