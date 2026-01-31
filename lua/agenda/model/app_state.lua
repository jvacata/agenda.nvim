---@class AppState
---@field private _tasks Task[]
---@field private _selected_index number|nil
---@field private _detail_index number|nil
---@field private _active_window WindowType
---@field private _subscribers function[]
local AppState = {}

AppState._tasks = {}
AppState._selected_index = nil
AppState._detail_index = nil
AppState._active_window = "list"
AppState._subscribers = {}

-- Subscriber pattern for state change notifications

---Subscribe to state changes
---@param callback function
---@return number subscriber_id
function AppState:subscribe(callback)
    table.insert(self._subscribers, callback)
    return #self._subscribers
end

---Unsubscribe from state changes
---@param subscriber_id number
function AppState:unsubscribe(subscriber_id)
    self._subscribers[subscriber_id] = nil
end

---Notify all subscribers of state change
---@private
function AppState:_notify()
    for _, callback in pairs(self._subscribers) do
        if callback then
            callback()
        end
    end
end

-- Task management

---Get all tasks (returns a copy to prevent external mutation)
---@return Task[]
function AppState:get_tasks()
    local copy = {}
    for i, task in ipairs(self._tasks) do
        copy[i] = task
    end
    return copy
end

---Get task count
---@return number
function AppState:get_task_count()
    return #self._tasks
end

---Get task by index (1-based)
---@param index number
---@return Task|nil
function AppState:get_task(index)
    return self._tasks[index]
end

---Get task by id
---@param id string
---@return Task|nil
function AppState:get_task_by_id(id)
    for _, task in ipairs(self._tasks) do
        if task.id == id then
            return task
        end
    end
    return nil
end

---Add a new task
---@param task Task
function AppState:add_task(task)
    table.insert(self._tasks, task)
    if self._selected_index == nil then
        self._selected_index = 0
    end
    self:_notify()
end

---Update an existing task
---@param task Task
---@return boolean success
function AppState:update_task(task)
    for i, existing in ipairs(self._tasks) do
        if existing.id == task.id then
            self._tasks[i] = task
            self:_notify()
            return true
        end
    end
    return false
end

---Add or update a task
---@param task Task
function AppState:add_or_update_task(task)
    if not self:update_task(task) then
        self:add_task(task)
    end
end

---Remove a task by id
---@param task_id string
---@return boolean success
function AppState:remove_task(task_id)
    for i, task in ipairs(self._tasks) do
        if task.id == task_id then
            table.remove(self._tasks, i)
            -- Adjust selected index if needed
            local task_count = #self._tasks
            if task_count == 0 then
                self._selected_index = nil
            elseif self._selected_index ~= nil and self._selected_index >= task_count then
                self._selected_index = task_count - 1
            end
            self:_notify()
            return true
        end
    end
    return false
end

---Get index of a task (0-based for UI compatibility)
---@param task_id string
---@return number|nil
function AppState:get_task_index(task_id)
    for i, task in ipairs(self._tasks) do
        if task.id == task_id then
            return i - 1
        end
    end
    return nil
end

---Check if a task exists
---@param task_id string
---@return boolean
function AppState:task_exists(task_id)
    return self:get_task_by_id(task_id) ~= nil
end

---Clear all tasks
function AppState:clear_tasks()
    self._tasks = {}
    self._selected_index = nil
    self._detail_index = nil
    self:_notify()
end

-- Selection management

---Get selected index (0-based)
---@return number|nil
function AppState:get_selected_index()
    return self._selected_index
end

---Set selected index (0-based)
---@param index number|nil
function AppState:set_selected_index(index)
    self._selected_index = index
    self:_notify()
end

---Get currently selected task
---@return Task|nil
function AppState:get_selected_task()
    if self._selected_index == nil then
        return nil
    end
    return self._tasks[self._selected_index + 1]
end

---Move selection up
---@return boolean moved
function AppState:move_selection_up()
    if self._selected_index == nil or self._selected_index <= 0 then
        return false
    end
    self._selected_index = self._selected_index - 1
    self:_notify()
    return true
end

---Move selection down
---@return boolean moved
function AppState:move_selection_down()
    if self._selected_index == nil then
        return false
    end
    local task_count = #self._tasks
    if self._selected_index >= task_count - 1 then
        return false
    end
    self._selected_index = self._selected_index + 1
    self:_notify()
    return true
end

---Select task by id
---@param task_id string
---@return boolean success
function AppState:select_task(task_id)
    local index = self:get_task_index(task_id)
    if index ~= nil then
        self._selected_index = index
        self:_notify()
        return true
    end
    return false
end

-- Detail index management

---Get detail index (0-based)
---@return number|nil
function AppState:get_detail_index()
    return self._detail_index
end

---Set detail index (0-based)
---@param index number|nil
function AppState:set_detail_index(index)
    self._detail_index = index
    self:_notify()
end

-- Active window management

---Get active window
---@return WindowType
function AppState:get_active_window()
    return self._active_window
end

---Set active window
---@param window WindowType
function AppState:set_active_window(window)
    self._active_window = window
    self:_notify()
end

-- State reset

---Reset all state to initial values
function AppState:reset()
    self._tasks = {}
    self._selected_index = nil
    self._detail_index = nil
    self._active_window = "list"
    self._subscribers = {}
end

---Initialize state with tasks (used during load)
---@param tasks Task[]
function AppState:init_with_tasks(tasks)
    self._tasks = tasks or {}
    if #self._tasks > 0 then
        self._selected_index = 0
    else
        self._selected_index = nil
    end
    self._detail_index = nil
    self._active_window = "list"
    self:_notify()
end

return AppState
