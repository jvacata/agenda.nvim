---@class TaskStore
---@field private _tasks Task[]
local TaskStore = {}

TaskStore._tasks = {}

---Get all tasks (returns a copy to prevent external mutation)
---@return Task[]
function TaskStore:get_tasks()
    local copy = {}
    for i, task in ipairs(self._tasks) do
        copy[i] = task
    end
    return copy
end

---Get task count
---@return number
function TaskStore:get_task_count()
    return #self._tasks
end

---Get task by index (1-based)
---@param index number
---@return Task|nil
function TaskStore:get_task(index)
    return self._tasks[index]
end

---Add a new task
---@param task Task
function TaskStore:add_task(task)
    table.insert(self._tasks, task)
end

---Update an existing task
---@param task Task
---@return boolean success
function TaskStore:update_task(task)
    for i, existing in ipairs(self._tasks) do
        if existing.id == task.id then
            self._tasks[i] = task
            return true
        end
    end
    return false
end

---Remove a task by id
---@param task_id string
---@return boolean success
function TaskStore:remove_task(task_id)
    for i, task in ipairs(self._tasks) do
        if task.id == task_id then
            table.remove(self._tasks, i)
            return true
        end
    end
    return false
end

---Get index of a task (0-based for UI compatibility)
---@param task_id string
---@return number|nil
function TaskStore:get_task_index(task_id)
    for i, task in ipairs(self._tasks) do
        if task.id == task_id then
            return i - 1
        end
    end
    return nil
end

---Initialize state with tasks (used during load)
---@param tasks Task[]
function TaskStore:init_with_tasks(tasks)
    self._tasks = tasks or {}
end

---Reset all state to initial values
function TaskStore:reset()
    self._tasks = {}
end

return TaskStore
