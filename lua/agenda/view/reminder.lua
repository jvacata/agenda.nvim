local ReminderView = {}

local window_config = require('agenda.config.window')

---@type number|nil
ReminderView._bufnr = nil
---@type number|nil
ReminderView._winnr = nil
---@type number|nil
ReminderView._close_timer = nil

---Show a reminder popup with overdue tasks
---@param tasks Task[] List of overdue tasks to display
---@param duration_seconds number How long the popup stays visible
function ReminderView:show(tasks, duration_seconds)
    self:close()

    local lines = { "Overdue tasks:" }
    for _, task in ipairs(tasks) do
        table.insert(lines, "  - " .. task.title)
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    local config = window_config:reminder_window(#lines)
    local winnr = vim.api.nvim_open_win(bufnr, false, config)

    self._bufnr = bufnr
    self._winnr = winnr

    self._close_timer = vim.defer_fn(function()
        self:close()
    end, duration_seconds * 1000)
end

---Close the reminder popup
function ReminderView:close()
    if self._close_timer then
        self._close_timer = nil
    end
    if self._winnr and vim.api.nvim_win_is_valid(self._winnr) then
        vim.api.nvim_win_close(self._winnr, true)
    end
    if self._bufnr and vim.api.nvim_buf_is_valid(self._bufnr) then
        vim.api.nvim_buf_delete(self._bufnr, { force = true })
    end
    self._winnr = nil
    self._bufnr = nil
end

return ReminderView
