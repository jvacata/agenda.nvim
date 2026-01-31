---@alias KanbanColumn "open" | "in_progress" | "done"

---@class KanbanUIState
---@field private _selected_column KanbanColumn
---@field private _selected_row number|nil
local KanbanUIState = {}

KanbanUIState._selected_column = "open"
KanbanUIState._selected_row = nil

---Get selected column
---@return KanbanColumn
function KanbanUIState:get_selected_column()
    return self._selected_column
end

---Set selected column
---@param column KanbanColumn
function KanbanUIState:set_selected_column(column)
    self._selected_column = column
end

---Get selected row (0-based)
---@return number|nil
function KanbanUIState:get_selected_row()
    return self._selected_row
end

---Set selected row (0-based)
---@param row number|nil
function KanbanUIState:set_selected_row(row)
    self._selected_row = row
end

---Reset all state to initial values
function KanbanUIState:reset()
    self._selected_column = "open"
    self._selected_row = nil
end

return KanbanUIState
