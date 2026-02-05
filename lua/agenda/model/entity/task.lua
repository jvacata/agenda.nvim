---@alias TaskStatus "todo"|"in_progress"|"done"

---@class Task
---@field id string -- id in uuid format
---@field title string
---@field status TaskStatus
---@field project_id string|nil -- optional project reference
---@field description string|nil -- optional task description

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
        status = status or "todo",
        project_id = nil,
        description = nil
    }
end

---Create a copy of task with updated title
---@param task Task
---@param new_title string
---@return Task
function Task.with_title(task, new_title)
    return {
        id = task.id,
        title = new_title,
        status = task.status,
        project_id = task.project_id,
        description = task.description
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
        status = new_status,
        project_id = task.project_id,
        description = task.description
    }
end

---Create a copy of task with updated project
---@param task Task
---@param project_id string|nil
---@return Task
function Task.with_project(task, project_id)
    return {
        id = task.id,
        title = task.title,
        status = task.status,
        project_id = project_id,
        description = task.description
    }
end

---Create a copy of task with updated description
---@param task Task
---@param new_description string|nil
---@return Task
function Task.with_description(task, new_description)
    return {
        id = task.id,
        title = task.title,
        status = task.status,
        project_id = task.project_id,
        description = new_description
    }
end

---Get available status options
---@return TaskStatus[]
function Task.get_status_options()
    return { "todo", "in_progress", "done" }
end

return Task
