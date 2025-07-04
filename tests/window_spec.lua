-- Unit tests for window.lua module
local window = require("persist-window.window")

describe("persist-window.window", function()
  describe("get_floating_windows", function()
    it("should return empty table when no floating windows exist", function()
      -- Mock empty window list for all tabs
      local original_nvim_list_tabpages = vim.api.nvim_list_tabpages
      local original_nvim_tabpage_list_wins = vim.api.nvim_tabpage_list_wins
      vim.api.nvim_list_tabpages = function() return {1} end
      vim.api.nvim_tabpage_list_wins = function() return {} end
      
      local result = window.get_floating_windows()
      assert.are.same({}, result)
      
      -- Restore original functions
      vim.api.nvim_list_tabpages = original_nvim_list_tabpages
      vim.api.nvim_tabpage_list_wins = original_nvim_tabpage_list_wins
    end)
    
    it("should return floating windows from all tabs", function()
      -- Mock floating windows across tabs
      local original_nvim_list_tabpages = vim.api.nvim_list_tabpages
      local original_nvim_tabpage_list_wins = vim.api.nvim_tabpage_list_wins
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      
      vim.api.nvim_list_tabpages = function() return {1, 2} end
      vim.api.nvim_tabpage_list_wins = function(tab_id)
        if tab_id == 1 then
          return {1001, 1002}
        else
          return {1003}
        end
      end
      vim.api.nvim_win_get_config = function(win_id)
        local mock_configs = {
          [1001] = { relative = "" },      -- Not floating
          [1002] = { relative = "editor" }, -- Floating
          [1003] = { relative = "win" }     -- Floating
        }
        return mock_configs[win_id]
      end
      
      local result = window.get_floating_windows()
      assert.are.equal(2, #result)
      assert.are.equal(1002, result[1].window_id)
      assert.are.equal(1, result[1].tab_id)
      assert.are.equal(1003, result[2].window_id)
      assert.are.equal(2, result[2].tab_id)
      
      vim.api.nvim_list_tabpages = original_nvim_list_tabpages
      vim.api.nvim_tabpage_list_wins = original_nvim_tabpage_list_wins
      vim.api.nvim_win_get_config = original_nvim_win_get_config
    end)
  end)
  
  describe("get_window_config", function()
    it("should return nil for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function() return false end
      
      local result = window.get_window_config(9999)
      assert.is_nil(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)
    
    it("should return config for valid window", function()
      local mock_config = { relative = "editor", width = 80, height = 24 }
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_config = function() return mock_config end
      
      local result = window.get_window_config(1001)
      assert.are.same(mock_config, result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_config = original_nvim_win_get_config
    end)
  end)
  
  describe("is_window_visible", function()
    it("should return false for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function() return false end
      
      local result = window.is_window_visible(9999)
      assert.is_false(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)
    
    it("should return false for non-floating window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_config = function() return { relative = "" } end
      
      local result = window.is_window_visible(1001)
      assert.is_false(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_config = original_nvim_win_get_config
    end)
    
    it("should return false for off-screen window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_config = function() 
        return { relative = "editor", row = -1000, col = -1000 } 
      end
      
      local result = window.is_window_visible(1001)
      assert.is_false(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_config = original_nvim_win_get_config
    end)
    
    it("should return true for visible floating window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_config = function() 
        return { relative = "editor", row = 5, col = 10 } 
      end
      
      local result = window.is_window_visible(1001)
      assert.is_true(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_config = original_nvim_win_get_config
    end)
  end)
  
  describe("get_window_buffer_name", function()
    it("should return [Invalid] for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function() return false end
      
      local result = window.get_window_buffer_name(9999)
      assert.are.equal("[Invalid]", result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)
    
    it("should return [No Name] for unnamed buffer", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_buf_get_name = vim.api.nvim_buf_get_name
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_buf = function() return 1 end
      vim.api.nvim_buf_get_name = function() return "" end
      
      local result = window.get_window_buffer_name(1001)
      assert.are.equal("[No Name]", result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_buf_get_name = original_nvim_buf_get_name
    end)
    
    it("should return filename for named buffer", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_buf_get_name = vim.api.nvim_buf_get_name
      local original_fnamemodify = vim.fn.fnamemodify
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_buf = function() return 1 end
      vim.api.nvim_buf_get_name = function() return "/path/to/file.txt" end
      vim.fn.fnamemodify = function(path, modifier) 
        if modifier == ":t" then return "file.txt" end
        return path
      end
      
      local result = window.get_window_buffer_name(1001)
      assert.are.equal("file.txt", result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_buf_get_name = original_nvim_buf_get_name
      vim.fn.fnamemodify = original_fnamemodify
    end)
  end)
  
  describe("validate_window", function()
    it("should return false for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function() return false end
      
      local result = window.validate_window(9999)
      assert.is_false(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)
    
    it("should return false for non-floating window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_config = function() return { relative = "" } end
      
      local result = window.validate_window(1001)
      assert.is_false(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_config = original_nvim_win_get_config
    end)
    
    it("should return true for valid floating window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_get_config = vim.api.nvim_win_get_config
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_get_config = function() return { relative = "editor" } end
      
      local result = window.validate_window(1001)
      assert.is_true(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_get_config = original_nvim_win_get_config
    end)
  end)
  
  describe("hide_window", function()
    it("should return false for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function() return false end
      
      local result = window.hide_window(9999)
      assert.is_false(result)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)
    
    it("should return true when successfully hiding window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_set_config = vim.api.nvim_win_set_config
      local config_called = false
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_set_config = function(win_id, config)
        config_called = true
        assert.are.equal(-1000, config.row)
        assert.are.equal(-1000, config.col)
        assert.are.equal(1, config.width)
        assert.are.equal(1, config.height)
      end
      
      local result = window.hide_window(1001)
      assert.is_true(result)
      assert.is_true(config_called)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_set_config = original_nvim_win_set_config
    end)
  end)
  
  describe("show_window", function()
    it("should return false for invalid window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      vim.api.nvim_win_is_valid = function() return false end
      
      local success, new_win_id = window.show_window(9999, {})
      assert.is_false(success)
      assert.is_nil(new_win_id)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
    end)
    
    it("should return true when successfully showing window", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_win_set_config = vim.api.nvim_win_set_config
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage
      local original_nvim_list_tabpages = vim.api.nvim_list_tabpages
      local original_nvim_tabpage_list_wins = vim.api.nvim_tabpage_list_wins
      local config_called = false
      local test_config = { relative = "editor", row = 5, col = 10, width = 20, height = 15 }
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_set_config = function(win_id, config)
        config_called = true
        assert.are.same(test_config, config)
      end
      vim.api.nvim_get_current_tabpage = function() return 1 end
      vim.api.nvim_list_tabpages = function() return {1} end
      vim.api.nvim_tabpage_list_wins = function() return {1001} end
      
      local success, new_win_id = window.show_window(1001, test_config)
      assert.is_true(success)
      assert.is_nil(new_win_id)  -- Should be nil when window is in same tab
      assert.is_true(config_called)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_win_set_config = original_nvim_win_set_config
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
      vim.api.nvim_list_tabpages = original_nvim_list_tabpages
      vim.api.nvim_tabpage_list_wins = original_nvim_tabpage_list_wins
    end)
    
    it("should recreate window when showing in different tab", function()
      local original_nvim_win_is_valid = vim.api.nvim_win_is_valid
      local original_nvim_get_current_tabpage = vim.api.nvim_get_current_tabpage
      local original_nvim_list_tabpages = vim.api.nvim_list_tabpages
      local original_nvim_tabpage_list_wins = vim.api.nvim_tabpage_list_wins
      local original_nvim_win_get_buf = vim.api.nvim_win_get_buf
      local original_nvim_open_win = vim.api.nvim_open_win
      local original_nvim_win_set_config = vim.api.nvim_win_set_config
      
      local new_window_created = false
      local hide_called = false
      local test_config = { relative = "editor", row = 5, col = 10, width = 20, height = 15 }
      
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_get_current_tabpage = function() return 2 end  -- Current tab is 2
      vim.api.nvim_list_tabpages = function() return {1, 2} end
      vim.api.nvim_tabpage_list_wins = function(tab)
        if tab == 1 then return {1001} end  -- Window 1001 is in tab 1
        if tab == 2 then return {1002} end  -- Different windows in tab 2
        return {}
      end
      vim.api.nvim_win_get_buf = function() return 42 end
      vim.api.nvim_open_win = function(buf_id, enter, config)
        new_window_created = true
        assert.are.equal(42, buf_id)
        assert.are.same(test_config, config)
        return 1003  -- New window ID
      end
      vim.api.nvim_win_set_config = function(win_id, config)
        hide_called = true
        assert.are.equal(1001, win_id)
        assert.are.equal(-1000, config.row)
      end
      
      local success, new_win_id = window.show_window(1001, test_config)
      assert.is_true(success)
      assert.are.equal(1003, new_win_id)
      assert.is_true(new_window_created)
      assert.is_true(hide_called)
      
      vim.api.nvim_win_is_valid = original_nvim_win_is_valid
      vim.api.nvim_get_current_tabpage = original_nvim_get_current_tabpage
      vim.api.nvim_list_tabpages = original_nvim_list_tabpages
      vim.api.nvim_tabpage_list_wins = original_nvim_tabpage_list_wins
      vim.api.nvim_win_get_buf = original_nvim_win_get_buf
      vim.api.nvim_open_win = original_nvim_open_win
      vim.api.nvim_win_set_config = original_nvim_win_set_config
    end)
  end)
end)