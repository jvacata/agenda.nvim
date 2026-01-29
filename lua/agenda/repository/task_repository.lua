local M = {}

local value_list = require('agenda.ui.list')

local tasks = value_list:new()

-- @param task Task
M.add = function(task)
    tasks:add(task)
end

M.remove = function(task)
    tasks:remove(task)
end

M.get_all = function()
    return tasks:get_all()
end

M.size = function()
    return #tasks:get_all()
end

M.clear = function()
    tasks:clear()
end

M.exists = function(task)
    for _, existing_task in ipairs(M.get_all()) do
        if existing_task.id == task.id then
            break
        end
    end
end


return M
