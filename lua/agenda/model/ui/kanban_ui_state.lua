---@alias KanbanColumn "open" | "in_progress" | "done"
---@alias KanbanFocus "project_list" | "board"

---@class KanbanUIState
---@field private _selected_column KanbanColumn
---@field private _selected_row number|nil
---@field private _selected_project_id string|nil
---@field private _focus KanbanFocus
---@field private _project_list_index number
local KanbanUIState = {}

KanbanUIState._selected_column = "open"
KanbanUIState._selected_row = nil
KanbanUIState._selected_project_id = nil
KanbanUIState._focus = "project_list"
KanbanUIState._project_list_index = 0

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

---Get selected project id
---@return string|nil
function KanbanUIState:get_selected_project_id()
    return self._selected_project_id
end

---Set selected project id
---@param project_id string|nil
function KanbanUIState:set_selected_project_id(project_id)
    self._selected_project_id = project_id
end

---Get current focus
---@return KanbanFocus
function KanbanUIState:get_focus()
    return self._focus
end

---Set current focus
---@param focus KanbanFocus
function KanbanUIState:set_focus(focus)
    self._focus = focus
end

---Get project list index (0-based)
---@return number
function KanbanUIState:get_project_list_index()
    return self._project_list_index
end

---Set project list index (0-based)
---@param index number
function KanbanUIState:set_project_list_index(index)
    self._project_list_index = index
end

---Reset all state to initial values
function KanbanUIState:reset()
    self._selected_column = "open"
    self._selected_row = nil
    self._selected_project_id = nil
    self._focus = "project_list"
    self._project_list_index = 0
end

return KanbanUIState
