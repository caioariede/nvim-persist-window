---@class PersistWindow.Window
local M = {}

---Get all floating windows across all tabs
---@return table[] floating_wins List of floating window info: {window_id, tab_id, config}
function M.get_floating_windows()
  local floating_wins = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        table.insert(floating_wins, {
          window_id = win,
          tab_id = tab,
          config = config
        })
      end
    end
  end
  return floating_wins
end

---Get window configuration
---@param win_id number Window ID
---@return table|nil config Window configuration or nil if invalid
function M.get_window_config(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return nil
  end
  return vim.api.nvim_win_get_config(win_id)
end

---Check if window is visible (not off-screen)
---@param win_id number Window ID
---@return boolean visible True if window is visible
function M.is_window_visible(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return false
  end
  
  local config = vim.api.nvim_win_get_config(win_id)
  if config.relative == "" then
    return false
  end
  
  -- Check if window is positioned off-screen (hidden)
  return config.row >= 0 and config.col >= 0
end

---Get window dimensions
---@param win_id number Window ID
---@return number|nil width Window width or nil if invalid
---@return number|nil height Window height or nil if invalid
function M.get_window_dimensions(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return nil, nil
  end
  
  local config = vim.api.nvim_win_get_config(win_id)
  return config.width, config.height
end

---Get window position
---@param win_id number Window ID
---@return number|nil row Window row or nil if invalid
---@return number|nil col Window column or nil if invalid
function M.get_window_position(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return nil, nil
  end
  
  local config = vim.api.nvim_win_get_config(win_id)
  return config.row, config.col
end

---Get buffer name for window
---@param win_id number Window ID
---@return string buffer_name Buffer name or "[No Name]"
function M.get_window_buffer_name(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return "[Invalid]"
  end
  
  local buf_id = vim.api.nvim_win_get_buf(win_id)
  local name = vim.api.nvim_buf_get_name(buf_id)
  
  if name == "" then
    return "[No Name]"
  end
  
  -- Return just the filename, not the full path
  return vim.fn.fnamemodify(name, ":t")
end

---Get buffer line count for window
---@param win_id number Window ID
---@return number|nil line_count Number of lines in buffer or nil if invalid
function M.get_window_buffer_line_count(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return nil
  end
  
  local buf_id = vim.api.nvim_win_get_buf(win_id)
  return vim.api.nvim_buf_line_count(buf_id)
end

---Validate window ID
---@param win_id number Window ID to validate
---@return boolean valid True if window is valid and floating
function M.validate_window(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return false
  end
  
  local config = vim.api.nvim_win_get_config(win_id)
  return config.relative ~= ""
end

---Hide a floating window by moving it off-screen
---@param win_id number Window ID to hide
---@return boolean success True if window was hidden successfully
function M.hide_window(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return false
  end
  
  -- Move window far off-screen to hide it while keeping it alive
  local success, _ = pcall(vim.api.nvim_win_set_config, win_id, {
    relative = 'editor',
    row = -1000,
    col = -1000,
    width = 1,
    height = 1,
  })
  
  return success
end

---Show a floating window with the given configuration
---@param win_id number Window ID to show
---@param config table Window configuration to restore
---@return boolean success True if window was shown successfully
---@return number|nil new_win_id New window ID if window was recreated
function M.show_window(win_id, config)
  if not vim.api.nvim_win_is_valid(win_id) then
    return false, nil
  end
  
  -- Check if the window is in the current tab
  local current_tab = vim.api.nvim_get_current_tabpage()
  local window_tab = nil
  
  -- Find which tab the window belongs to
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local tab_wins = vim.api.nvim_tabpage_list_wins(tab)
    for _, tab_win in ipairs(tab_wins) do
      if tab_win == win_id then
        window_tab = tab
        break
      end
    end
    if window_tab then
      break
    end
  end
  
  if window_tab == current_tab then
    -- Window is in current tab, just restore its configuration
    local success, _ = pcall(vim.api.nvim_win_set_config, win_id, config)
    return success, nil
  else
    -- Window is in a different tab, recreate it in the current tab
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    
    -- Create new window in current tab with the same buffer
    local new_win_id = vim.api.nvim_open_win(buf_id, false, config)
    
    -- Hide the original window
    M.hide_window(win_id)
    
    return true, new_win_id
  end
end

return M