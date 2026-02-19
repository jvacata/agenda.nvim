local ReminderService = {}

local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local string_utils = require('agenda.util.string')
local reminder_view = require('agenda.view.reminder')

---@type table<string, number> Runtime-only map of task_id -> last reminded timestamp
ReminderService._reminded_at = {}
---@type userdata|nil
ReminderService._timer = nil

---Load all tasks directly from disk (independent of task_store)
---@return Task[]
function ReminderService:_load_tasks_from_disk()
    local tasks = {}
    local task_files = file_utils:get_dir_files(global_config.workspace_task_path)
    for _, task_file in ipairs(task_files) do
        local ok, data = pcall(file_utils.load_file, file_utils, task_file)
        if ok and type(data) == "table" and data.id ~= nil and string_utils:is_valid_id(data.id) then
            table.insert(tasks, data)
        end
    end
    return tasks
end

---Check for overdue tasks and show reminders
function ReminderService:check_overdue_tasks()
    local config = global_config.user_config.reminder
    local now = os.time()
    local remind_interval_secs = config.remind_interval * 60

    local tasks = self:_load_tasks_from_disk()
    local overdue = {}

    for _, task in ipairs(tasks) do
        if task.due_at and task.status ~= "done" then
            local overdue_by = now - task.due_at
            if overdue_by >= remind_interval_secs then
                local last_reminded = self._reminded_at[task.id]
                if not last_reminded or (now - last_reminded) >= remind_interval_secs then
                    table.insert(overdue, task)
                end
            end
        end
    end

    if #overdue > 0 then
        for _, task in ipairs(overdue) do
            self._reminded_at[task.id] = now
        end
        reminder_view:show(overdue, config.popup_duration)
    end
end

---Start the reminder timer
function ReminderService:start()
    local config = global_config.user_config.reminder
    if not config.enabled then
        return
    end

    self:stop()

    local timer = vim.uv.new_timer()
    local interval_ms = config.check_interval * 1000

    timer:start(interval_ms, interval_ms, vim.schedule_wrap(function()
        self:check_overdue_tasks()
    end))

    self._timer = timer

    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            self:stop()
        end,
        once = true,
    })
end

---Stop the reminder timer
function ReminderService:stop()
    if self._timer then
        self._timer:stop()
        self._timer:close()
        self._timer = nil
    end
    reminder_view:close()
end

---Reset runtime state
function ReminderService:reset()
    self:stop()
    self._reminded_at = {}
end

return ReminderService
