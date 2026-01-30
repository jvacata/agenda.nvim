local TaskRepository = {}

local value_list = require('agenda.ui.list')

local task_list = value_list:new()

function TaskRepository:add_or_update(task)
    task_list:add_or_update(task)
end

function TaskRepository:remove(task)
    task_list:remove(task)
end

function TaskRepository:get_all()
    return task_list:get_all()
end

function TaskRepository:get_index(task)
    return task_list:get_index(task)
end

function TaskRepository:size()
    return #task_list:get_all()
end

function TaskRepository:clear()
    task_list:clear()
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
