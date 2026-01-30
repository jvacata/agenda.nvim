local TaskService = {}

local task_repository = require('agenda.repository.task_repository')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local string_utils = require('agenda.util.string')

function TaskService:update_task(task)
    if not string_utils:is_valid_id(task.id) then
        error("Task must have a valid id to be updated")
    end

    task_repository:add_or_update(task)
    file_utils:save_file(global_config.workspace_task_path, task.id, vim.json.encode(task))
end

function TaskService:delete_task(task)
    task_repository:remove(task)
    file_utils:remove_file(global_config.workspace_task_path, task.id)
end

function TaskService:init_load_tasks()
    task_repository:clear()
    local task_files = file_utils:get_dir_files(global_config.workspace_task_path)
    for _, task_file in ipairs(task_files) do
        local data = file_utils:load_file(task_file)
        if type(data) ~= "table" or data.id == nil or not string_utils:is_valid_id(data.id) then
            goto continue
        end
        task_repository:add_or_update(data)
        ::continue::
    end
end

function TaskService:get_current_selected_task(current_line_index)
    return task_repository:get_all()[current_line_index + 1]
end

return TaskService
