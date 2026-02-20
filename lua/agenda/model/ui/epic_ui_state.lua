---@alias EpicWindowType "list" | "detail"

---@class EpicUIState
---@field private _selected_index number|nil
---@field private _detail_index number|nil
---@field private _active_window EpicWindowType
local EpicUIState = {}

EpicUIState._selected_index = nil
EpicUIState._detail_index = nil
EpicUIState._active_window = "list"

---Get selected index (0-based)
---@return number|nil
function EpicUIState:get_selected_index()
    return self._selected_index
end

---Set selected index (0-based)
---@param index number|nil
function EpicUIState:set_selected_index(index)
    self._selected_index = index
end

---Get detail index (0-based)
---@return number|nil
function EpicUIState:get_detail_index()
    return self._detail_index
end

---Set detail index (0-based)
---@param index number|nil
function EpicUIState:set_detail_index(index)
    self._detail_index = index
end

---Get active window
---@return EpicWindowType
function EpicUIState:get_active_window()
    return self._active_window
end

---Set active window
---@param window EpicWindowType
function EpicUIState:set_active_window(window)
    self._active_window = window
end

---Reset all state to initial values
function EpicUIState:reset()
    self._selected_index = nil
    self._detail_index = nil
    self._active_window = "list"
end

return EpicUIState
