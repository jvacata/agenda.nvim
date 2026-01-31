local TaskView = {}

local constants = require('agenda.constants')
local window_util = require('agenda.util.window')
local global_config = require('agenda.config.global')
local window_config = require('agenda.config.window')

-- Buffer and window references (view infrastructure, not state)
-- @type number
TaskView.list_bufnr = nil
-- @type number
TaskView.list_winnr = nil
-- @type number
TaskView.detail_bufnr = nil
-- @type number
TaskView.detail_winnr = nil

function TaskView:init()
    self.list_bufnr, self.list_winnr = window_util:get_win("agenda_task_list", window_config:task_list_window())
    self.detail_bufnr, self.detail_winnr = window_util:get_win("agenda_task_detail", window_config:task_detail_window())
    vim.api.nvim_set_current_win(self.list_winnr)
end

---Render the task view with provided data
---@param view_data {tasks: Task[], selected_index: number|nil, active_window: WindowType, detail_index: number|nil}
function TaskView:render(view_data)
    window_util:hide_cursor()
    self:render_task_list(view_data)
    self:render_task_detail(view_data)
end

---Render the task list
---@param view_data {tasks: Task[], selected_index: number|nil, active_window: WindowType, detail_index: number|nil}
function TaskView:render_task_list(view_data)
    window_util:clean_buffer(self.list_bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.list_bufnr })
    for i, task in ipairs(view_data.tasks) do
        vim.api.nvim_buf_set_lines(self.list_bufnr, i - 1, i, false, { task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.list_bufnr })

    self:highlight_list_line(view_data)
end

---Render the task detail panel
---@param view_data {tasks: Task[], selected_index: number|nil, active_window: WindowType, detail_index: number|nil}
function TaskView:render_task_detail(view_data)
    window_util:clean_buffer(self.detail_bufnr)
    if #view_data.tasks == 0 or view_data.selected_index == nil then
        return
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.detail_bufnr })
    local task = view_data.tasks[view_data.selected_index + 1]
    if task then
        vim.api.nvim_buf_set_lines(self.detail_bufnr, constants.ID_LINE_INDEX, constants.ID_LINE_INDEX + 1, false,
            { "Id: " .. task.id })
        vim.api.nvim_buf_set_lines(self.detail_bufnr, constants.TITLE_LINE_INDEX, constants.TITLE_LINE_INDEX + 1, false,
            { "Title: " .. task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.detail_bufnr })

    self:highlight_detail_line(view_data)
end

---Highlight the selected line in the list
---@param view_data {tasks: Task[], selected_index: number|nil, active_window: WindowType, detail_index: number|nil}
function TaskView:highlight_list_line(view_data)
    self:clear_marks(self.list_bufnr)

    if view_data.selected_index == nil then
        return
    end

    local task_count = #view_data.tasks
    if task_count > 0 then
        local task = view_data.tasks[view_data.selected_index + 1]
        if task then
            local len = #task.title
            self:highlight_line(self.list_bufnr, view_data.selected_index, len)
        end
    end
end

---Highlight the selected line in the detail panel
---@param view_data {tasks: Task[], selected_index: number|nil, active_window: WindowType, detail_index: number|nil}
function TaskView:highlight_detail_line(view_data)
    self:clear_marks(self.detail_bufnr)

    if view_data.detail_index == nil or view_data.active_window ~= "detail" then
        return
    end

    local line = vim.api.nvim_buf_get_lines(self.detail_bufnr, view_data.detail_index, view_data.detail_index + 1, false)
        [1]
    if line then
        local len = #line
        self:highlight_line(self.detail_bufnr, view_data.detail_index, len)
    end
end

---Apply highlight to a line
---@param bufnr number
---@param line_index number
---@param len number
function TaskView:highlight_line(bufnr, line_index, len)
    vim.api.nvim_buf_set_extmark(bufnr, global_config.ns, line_index, 0, { end_col = len, hl_group = "Search" })
end

---Clear all extmarks from buffer
---@param bufnr number
function TaskView:clear_marks(bufnr)
    local all = vim.api.nvim_buf_get_extmarks(bufnr, global_config.ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bufnr, global_config.ns, mark[1])
    end
end

function TaskView:destroy()
    vim.api.nvim_win_close(self.list_winnr, true)
    vim.api.nvim_win_close(self.detail_winnr, true)
end

return TaskView
