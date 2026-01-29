local M = {}

local task_repository = require('agenda.repository.task_repository')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')

M.update_task = function(task)
    if not task_repository.exists(task) then
        task_repository.add(task)
    end

    file_utils.save_file(global_config.tasks_path, task.id, vim.json.encode(task))
end

M.delete_task = function(task)
    task_repository.remove(task)
    file_utils.remove_file(global_config.tasks_path, task.id)
end

M.init_load_tasks = function()
    task_repository.clear()
    local task_files = file_utils.get_dir_files(global_config.tasks_path)
    for _, task_file in ipairs(task_files) do
        local data = file_utils.load_file(task_file)
        task_repository.add(data)
    end
end

return M
