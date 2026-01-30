local TaskService = {}

local task_repository = require('agenda.repository.task_repository')
local task_view = require('agenda.view.task')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')

function TaskService:update_task(task)
    if not task_repository:exists(task) then
        task_repository:add(task)
    end

    file_utils:save_file(global_config.tasks_path, task.id, vim.json.encode(task))
end

function TaskService:delete_task(task)
    task_repository:remove(task)
    file_utils:remove_file(global_config.tasks_path, task.id)
end

function TaskService:init_load_tasks()
    task_repository:clear()
    local task_files = file_utils:get_dir_files(global_config.tasks_path)
    for _, task_file in ipairs(task_files) do
        local data = file_utils:load_file(task_file)
        task_repository:add(data)
    end
end

function TaskService:get_current_selected_task()
    return task_repository:get_all()[task_view.current_line_index + 1]
end

return TaskService
