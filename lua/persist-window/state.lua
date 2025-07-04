---@class PersistWindow.State
local M = {}

---@class PersistWindow.WindowState
---@field window_id number The actual floating window ID
---@field buffer_id number The buffer ID in the window
---@field is_visible boolean Current visibility state
---@field last_tab number Last tab where window was visible
---@field config table Original window configuration
---@field metadata table Metadata about the window
---@field always_on_top boolean Keep window visible across tab switches

---@type PersistWindow.WindowState|nil
M.persisted_window = nil

---Set the persisted window
---@param win_id number Window ID to persist
---@return boolean success True if successfully persisted
function M.set_persisted_window(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return false
  end
  
  local buf_id = vim.api.nvim_win_get_buf(win_id)
  local config = vim.api.nvim_win_get_config(win_id)
  local current_tab = vim.api.nvim_get_current_tabpage()
  
  M.persisted_window = {
    window_id = win_id,
    buffer_id = buf_id,
    is_visible = true,
    last_tab = current_tab,
    config = config,
    metadata = {
      created_at = os.date("%Y-%m-%d %H:%M:%S"),
      persistent_id = tostring(win_id) .. "_" .. tostring(os.time()),
    },
    always_on_top = false,  -- Default to false, can be toggled later
  }
  
  return true
end

---Get the persisted window state
---@return PersistWindow.WindowState|nil state Persisted window state or nil
function M.get_persisted_window()
  return M.persisted_window
end

---Clear the persisted window
function M.clear_persisted_window()
  M.persisted_window = nil
end

---Check if a window ID is valid and still exists
---@param win_id number Window ID to validate
---@return boolean valid True if window is valid
function M.is_window_valid(win_id)
  return vim.api.nvim_win_is_valid(win_id)
end

---Update the visibility state of the persisted window
---@param is_visible boolean New visibility state
function M.update_visibility(is_visible)
  if M.persisted_window then
    M.persisted_window.is_visible = is_visible
  end
end

---Update the last tab where the window was visible
---@param tab_id number Tab ID
function M.update_last_tab(tab_id)
  if M.persisted_window then
    M.persisted_window.last_tab = tab_id
  end
end

---Update the window ID when window is recreated
---@param new_win_id number New window ID
function M.update_window_id(new_win_id)
  if M.persisted_window then
    M.persisted_window.window_id = new_win_id
  end
end

---Get the currently persisted window ID
---@return number|nil win_id Persisted window ID or nil
function M.get_persisted_window_id()
  if M.persisted_window then
    return M.persisted_window.window_id
  end
  return nil
end

---Toggle always on top setting for the persisted window
---@param value boolean|nil New value, or nil to toggle
function M.set_always_on_top(value)
  if M.persisted_window then
    if value == nil then
      M.persisted_window.always_on_top = not M.persisted_window.always_on_top
    else
      M.persisted_window.always_on_top = value
    end
  end
end

---Get always on top setting for the persisted window
---@return boolean|nil always_on_top Always on top setting or nil if no window
function M.get_always_on_top()
  if M.persisted_window then
    return M.persisted_window.always_on_top
  end
  return nil
end

return M