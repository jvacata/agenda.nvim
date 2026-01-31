local TaskService = {}

local app_state = require('agenda.model.app_state')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local string_utils = require('agenda.util.string')

---Save a task to disk
---@param task Task
function TaskService:save_task(task)
    if not string_utils:is_valid_id(task.id) then
        error("Task must have a valid id to be saved")
    end

    file_utils:save_file(global_config.workspace_task_path, task.id, vim.json.encode(task))
end

---Delete a task from disk
---@param task Task
function TaskService:delete_task(task)
    file_utils:remove_file(global_config.workspace_task_path, task.id)
end

---Load all tasks from disk into AppState
function TaskService:init_load_tasks()
    local tasks = {}
    local task_files = file_utils:get_dir_files(global_config.workspace_task_path)
    for _, task_file in ipairs(task_files) do
        local data = file_utils:load_file(task_file)
        if type(data) == "table" and data.id ~= nil and string_utils:is_valid_id(data.id) then
            table.insert(tasks, data)
        end
    end
    app_state:init_with_tasks(tasks)
end

return TaskService
