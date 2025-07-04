---@class PersistWindow
local M = {}

local window = require("persist-window.window")
local ui = require("persist-window.ui")
local state = require("persist-window.state")

-- Store configuration
M.config = {
  always_on_top = false, -- Keep window visible across tab switches
}

---Setup function for the plugin (optional - for configuration only)
---@param opts table|nil Configuration options
function M.setup(opts)
  opts = opts or {}

  -- Merge user options with defaults
  M.config = vim.tbl_extend("force", M.config, opts)
end

---List all floating windows in the current tab
function M.list_windows()
  local floating_wins = window.get_floating_windows()
  local persisted_win_id = state.get_persisted_window_id()

  ui.list_floating_windows(floating_wins, persisted_win_id)
end

---Persist a floating window
---@param win_id_str string|nil Optional window ID as string
function M.persist_window(win_id_str)
  local floating_wins = window.get_floating_windows()

  if #floating_wins == 0 then
    ui.show_error("No floating windows found in any tab")
    return
  end

  local target_win_id

  if win_id_str and win_id_str ~= "" then
    -- User provided a specific window ID
    target_win_id = tonumber(win_id_str)
    if not target_win_id or not window.validate_window(target_win_id) then
      ui.show_error("Invalid window ID: " .. win_id_str)
      return
    end
  else
    -- Auto-select or prompt for selection
    if #floating_wins == 1 then
      target_win_id = floating_wins[1].window_id
    else
      target_win_id = ui.prompt_window_selection(floating_wins)
      if not target_win_id then
        return
      end
    end
  end

  -- Persist the window
  if state.set_persisted_window(target_win_id) then
    -- Apply global always_on_top setting to the newly persisted window
    state.set_always_on_top(M.config.always_on_top)
    ui.show_success("Window " .. target_win_id .. " persisted successfully")
  else
    ui.show_error("Failed to persist window " .. target_win_id)
  end
end

---Toggle the persisted floating window
function M.toggle_window()
  local persisted = state.get_persisted_window()

  if not persisted then
    ui.show_error("No window has been persisted yet")
    return
  end

  if not state.is_window_valid(persisted.window_id) then
    ui.show_error("Persisted window no longer exists")
    state.clear_persisted_window()
    return
  end

  local current_tab = vim.api.nvim_get_current_tabpage()

  if persisted.is_visible and window.is_window_visible(persisted.window_id) then
    -- Hide the window
    if window.hide_window(persisted.window_id) then
      state.update_visibility(false)
      ui.show_success("Persisted window hidden")
    else
      ui.show_error("Failed to hide persisted window")
    end
  else
    -- Show the window
    local success, new_win_id = window.show_window(persisted.window_id, persisted.config)
    if success then
      state.update_visibility(true)
      state.update_last_tab(current_tab)

      -- Update window ID if window was recreated
      if new_win_id then
        state.update_window_id(new_win_id)
      end

      ui.show_success("Persisted window shown")
    else
      ui.show_error("Failed to show persisted window")
    end
  end
end

---Show information about the persisted window
function M.show_window_info()
  local persisted = state.get_persisted_window()

  if not persisted then
    ui.show_error("No window has been persisted yet")
    return
  end

  if not state.is_window_valid(persisted.window_id) then
    ui.show_error("Persisted window no longer exists")
    state.clear_persisted_window()
    return
  end

  local buffer_name = window.get_window_buffer_name(persisted.window_id)
  local width, height = window.get_window_dimensions(persisted.window_id)
  local row, col = window.get_window_position(persisted.window_id)
  local current_tab = vim.api.nvim_get_current_tabpage()

  local info_lines = {
    "Persisted Window Info:",
    "- Window ID: " .. persisted.window_id,
    '- Buffer: "' .. buffer_name .. '"',
    "- Size: " .. width .. "x" .. height,
    "- Position: row " .. row .. ", col " .. col,
    "- Status: Currently " .. (persisted.is_visible and "visible" or "hidden") .. " in tab " .. current_tab,
    "- Always on top: " .. (persisted.always_on_top and "enabled" or "disabled"),
    "- Persisted: " .. persisted.metadata.created_at,
  }

  ui.show_info(table.concat(info_lines, "\n"))
end

---Parse always-on-top value from string argument
---@param value string|nil String value to parse
---@return boolean|nil parsed_value
local function parse_always_on_top_value(value)
  if value == "on" or value == "true" or value == "1" then
    return true
  elseif value == "off" or value == "false" or value == "0" then
    return false
  end
  return nil
end

---Toggle or set always-on-top mode for persisted window
---@param value string|nil "on", "off", or nil to toggle
function M.toggle_always_on_top(value)
  local persisted = state.get_persisted_window()

  if not persisted then
    ui.show_error("No window has been persisted yet")
    return
  end

  if not state.is_window_valid(persisted.window_id) then
    ui.show_error("Persisted window no longer exists")
    state.clear_persisted_window()
    return
  end

  local new_value = parse_always_on_top_value(value)
  state.set_always_on_top(new_value)

  local current_setting = state.get_always_on_top()
  ui.show_success("Always-on-top mode " .. (current_setting and "enabled" or "disabled"))
end

---Handle tab switch event to auto-hide persisted windows or keep them on top
function M.handle_tab_switch()
  local persisted = state.get_persisted_window()

  if not persisted then
    return
  end

  -- Check if the persisted window is valid
  if not state.is_window_valid(persisted.window_id) then
    state.clear_persisted_window()
    return
  end

  -- If always_on_top is enabled and window is visible, show it in the new tab
  if persisted.always_on_top and persisted.is_visible then
    -- Show the window in the current tab
    local current_tab = vim.api.nvim_get_current_tabpage()
    local success, new_win_id = window.show_window(persisted.window_id, persisted.config)

    if success then
      state.update_last_tab(current_tab)
      -- Update window ID if window was recreated
      if new_win_id then
        state.update_window_id(new_win_id)
      end
    end
  else
    -- Original behavior: hide window when switching tabs
    -- Only proceed if window is currently visible
    if not persisted.is_visible then
      return
    end

    -- Check if the window is visible (not already hidden)
    if window.is_window_visible(persisted.window_id) then
      -- Hide the window
      if window.hide_window(persisted.window_id) then
        state.update_visibility(false)
      end
    end
  end
end

return M
