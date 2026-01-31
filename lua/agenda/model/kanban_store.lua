---@alias KanbanColumn "open" | "in_progress" | "done"

---@class KanbanStore
---@field private _columns table<KanbanColumn, Task[]>
local KanbanStore = {}

KanbanStore._columns = {
    open = {},
    in_progress = {},
    done = {}
}

---Get column names in display order
---@return KanbanColumn[]
function KanbanStore:get_column_names()
    return { "open", "in_progress", "done" }
end

---Get display title for a column
---@param column KanbanColumn
---@return string
function KanbanStore:get_column_title(column)
    local titles = {
        open = "Open",
        in_progress = "In Progress",
        done = "Done"
    }
    return titles[column] or column
end

---Get tasks for a specific column (returns a copy)
---@param column KanbanColumn
---@return Task[]
function KanbanStore:get_tasks(column)
    local copy = {}
    local tasks = self._columns[column] or {}
    for i, task in ipairs(tasks) do
        copy[i] = task
    end
    return copy
end

---Get all columns with their tasks (returns copies)
---@return table<KanbanColumn, Task[]>
function KanbanStore:get_all_columns()
    local result = {}
    for _, column in ipairs(self:get_column_names()) do
        result[column] = self:get_tasks(column)
    end
    return result
end

---Get task count for a column
---@param column KanbanColumn
---@return number
function KanbanStore:get_task_count(column)
    return #(self._columns[column] or {})
end

---Get task by column and index (1-based)
---@param column KanbanColumn
---@param index number
---@return Task|nil
function KanbanStore:get_task(column, index)
    local tasks = self._columns[column] or {}
    return tasks[index]
end

---Initialize with tasks (all tasks go to "open" column for now)
---@param tasks Task[]
function KanbanStore:init_with_tasks(tasks)
    self._columns = {
        open = tasks or {},
        in_progress = {},
        done = {}
    }
end

---Reset all state
function KanbanStore:reset()
    self._columns = {
        open = {},
        in_progress = {},
        done = {}
    }
end

return KanbanStore
