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
        status = status or "Open"
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
        status = task.status
    }
end

return Task
