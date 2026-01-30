local TaskRepository = {}

local value_list = require('agenda.ui.list')

local tasks = value_list:new()

-- @param task Task
function TaskRepository:add(task)
    tasks:add(task)
end

function TaskRepository:remove(task)
    tasks:remove(task)
end

function TaskRepository:get_all()
    return tasks:get_all()
end

function TaskRepository:size()
    return #tasks:get_all()
end

function TaskRepository:clear()
    tasks:clear()
end

function TaskRepository:exists(task)
    for _, existing_task in ipairs(self:get_all()) do
        if existing_task.id == task.id then
            return true
        end
    end
    return false
end

return TaskRepository
