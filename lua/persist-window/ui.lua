---@class PersistWindow.UI
local M = {}

local window = require("persist-window.window")

---Format window information for display
---@param win_info table Window info: {window_id, tab_id, config}
---@param index number Display index (1-based)
---@param is_persisted boolean Whether this window is currently persisted
---@param is_hidden boolean Whether this window is hidden/off-screen
---@return string formatted_line Formatted window display line
function M.format_window_display(win_info, index, is_persisted, is_hidden)
  local win_id = win_info.window_id
  local tab_id = win_info.tab_id
  local buffer_name = window.get_window_buffer_name(win_id)
  local width, height = window.get_window_dimensions(win_id)
  local row, col = window.get_window_position(win_id)

  if not width or not height or not row or not col then
    return string.format("%d. Window %d - [Invalid] [Tab %d]", index, win_id, tab_id)
  end

  local size_info = string.format("%dx%d", width, height)
  local pos_info = string.format("row %d, col %d", row, col)
  local tab_info = string.format(" [Tab %d]", tab_id)
  local persisted_indicator = is_persisted and " [PERSISTED]" or ""
  local hidden_indicator = is_hidden and " [HIDDEN]" or ""

  return string.format(
    '%d. Window %d - "%s" (%s at %s)%s%s%s',
    index,
    win_id,
    buffer_name,
    size_info,
    pos_info,
    tab_info,
    persisted_indicator,
    hidden_indicator
  )
end

---Display list of floating windows
---@param floating_wins table[] List of floating window info: {window_id, tab_id, config}
---@param persisted_win_id number|nil Currently persisted window ID
function M.list_floating_windows(floating_wins, persisted_win_id)
  if #floating_wins == 0 then
    M.show_info("No floating windows found in any tab")
    return
  end

  local lines = { "Floating Windows (All Tabs):" }

  for i, win_info in ipairs(floating_wins) do
    local is_persisted = persisted_win_id == win_info.window_id
    local is_hidden = window.is_window_visible(win_info.window_id) == false
    local formatted_line = M.format_window_display(win_info, i, is_persisted, is_hidden)
    table.insert(lines, formatted_line)
  end

  table.insert(lines, "")
  table.insert(lines, "Use :PersistWindow [ID] to persist a specific window")
  table.insert(lines, "Note: HIDDEN windows are persisted but currently off-screen")

  M.show_info(table.concat(lines, "\n"))
end

---Show informational message
---@param message string Message to display
function M.show_info(message)
  print(message)
end

---Show error message
---@param message string Error message to display
function M.show_error(message)
  vim.api.nvim_err_writeln("persist-window: " .. message)
end

---Show success message
---@param message string Success message to display
function M.show_success(message)
  print("persist-window: " .. message)
end

---Prompt user to select a window from a list
---@param floating_wins table[] List of floating window info: {window_id, tab_id, config}
---@return number|nil selected_win_id Selected window ID or nil if cancelled
function M.prompt_window_selection(floating_wins)
  if #floating_wins == 0 then
    M.show_error("No floating windows found")
    return nil
  end

  if #floating_wins == 1 then
    return floating_wins[1].window_id
  end

  -- Display available windows
  local lines = { "Multiple floating windows detected:" }
  for i, win_info in ipairs(floating_wins) do
    local is_hidden = window.is_window_visible(win_info.window_id) == false
    local formatted_line = M.format_window_display(win_info, i, false, is_hidden)
    table.insert(lines, formatted_line)
  end
  table.insert(lines, "")
  table.insert(lines, "Tip: Use :ListWindows to see all floating windows")

  M.show_info(table.concat(lines, "\n"))

  -- Get user input
  local input = vim.fn.input(string.format("Enter window number to persist (1-%d): ", #floating_wins))

  if input == "" then
    M.show_info("Selection cancelled")
    return nil
  end

  local selection = tonumber(input)
  if not selection or selection < 1 or selection > #floating_wins then
    M.show_error("Invalid selection. Please enter a number between 1 and " .. #floating_wins)
    return nil
  end

  return floating_wins[selection].window_id
end

return M
