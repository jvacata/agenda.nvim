---@alias TaskStatus "todo"|"in_progress"|"done"

---@class Task
---@field id string -- id in uuid format
---@field title string
---@field status TaskStatus

local Task = {}

local common_util = require('agenda.util.common')

---Create a new task with generated UUID
---@param title string
---@param status? TaskStatus
---@return Task
function Task.create(title, status)
    return {
        id = common_util:generate_uuid_v4(),
        title = title or "",
        status = status or "todo"
    }
end

---Validate a task object
---@param task any
---@return boolean is_valid
---@return string? error_message
function Task.is_valid(task)
    if type(task) ~= "table" then
        return false, "Task must be a table"
    end
    if type(task.id) ~= "string" or task.id == "" then
        return false, "Task must have a valid id"
    end
    if type(task.title) ~= "string" then
        return false, "Task must have a title"
    end
    return true, nil
end

---Create a copy of task with updated title
---@param task Task
---@param new_title string
---@return Task
function Task.with_title(task, new_title)
    return {
        id = task.id,
        title = new_title,
        status = task.status
    }
end

---Create a copy of task with updated status
---@param task Task
---@param new_status TaskStatus
---@return Task
function Task.with_status(task, new_status)
    return {
        id = task.id,
        title = task.title,
        status = new_status
    }
end

return Task
