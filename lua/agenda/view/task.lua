local TaskView = {}

local window_util = require('agenda.util.window')
local task_repository = require('agenda.repository.task_repository')

local global_config = require('agenda.config.global')
local window_config = require('agenda.config.window')

TaskView.current_line_index = 0
TaskView.current_detail_line_index = 0

TaskView.list_bufnr = nil
TaskView.list_winnr = nil

TaskView.detail_bufnr = nil
TaskView.detail_winnr = nil

TaskView.edit_bufnr = nil
TaskView.edit_winnr = nil

---@alias WindowType "list"|"detail"|"edit"

-- @type WindowType
local current_window = "list"

function TaskView:init()
    TaskView.list_bufnr, TaskView.list_winnr = window_util:get_win("agenda_task_list", window_config:task_list_window())
    TaskView.detail_bufnr, TaskView.detail_winnr = window_util:get_win("agenda_task_detail",
        window_config:task_detail_window())
end

function TaskView:render()
    TaskView:render_task_list()
    TaskView:render_task_detail()
end

function TaskView:render_task_list()
    window_util:clean_buffer(self.list_bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.list_bufnr })
    for i, task in pairs(task_repository:get_all()) do
        vim.api.nvim_buf_set_lines(self.list_bufnr, i - 1, i, false, { task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.list_bufnr })

    TaskView:highlight_list_line(self.list_bufnr)
end

function TaskView:render_task_detail()
    window_util:clean_buffer(self.detail_bufnr)
    if task_repository:size() == 0 then
        return
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.detail_bufnr })
    local task = task_repository:get_all()[self.current_line_index + 1]
    vim.api.nvim_buf_set_lines(self.detail_bufnr, 0, 1, false, { "Id: " .. task.id })
    vim.api.nvim_buf_set_lines(self.detail_bufnr, 1, 2, false, { "Title: " .. task.title })
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.detail_bufnr })

    TaskView:highlight_list_line(self.list_bufnr)
end

function TaskView:highlight_list_line(bufnr)
    TaskView:clear_marks(bufnr)

    local task_count = task_repository:size()
    if task_count > 0 then
        local len = #(task_repository:get_all()[self.current_line_index + 1].title)
        TaskView:highlight_line(bufnr, self.current_line_index, len)
    end
end

function TaskView:highlight_detail_line(bufnr)
    TaskView:clear_marks(bufnr)
    local len = #(vim.api.nvim_buf_get_lines(bufnr, self.current_detail_line_index, self.current_detail_line_index + 1, false)[1])
    TaskView:highlight_line(bufnr, self.current_detail_line_index, len)
end

function TaskView:highlight_line(bufnr, line_index, len)
    vim.api.nvim_buf_set_extmark(bufnr, global_config.ns, line_index, 0, { end_col = len, hl_group = "Search" })
end

function TaskView:clear_marks(bufnr)
    local all = vim.api.nvim_buf_get_extmarks(bufnr, global_config.ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bufnr, global_config.ns, mark[1])
    end
end

function TaskView:close()
    if current_window == "detail" then
        TaskView:clear_marks(self.detail_bufnr)
        current_window = "list"
    elseif current_window == "list" then
        vim.api.nvim_win_close(self.list_winnr, true)
        vim.api.nvim_win_close(self.detail_winnr, true)
    end
end

function TaskView:do_action(list_bufnr, detail_bufnr)
    if current_window == "list" then
        current_window = "detail"
        self.current_detail_line_index = 1
        TaskView:highlight_detail_line(detail_bufnr)
    elseif current_window == "detail" then
        local data = ""
        local task = task_repository:get_all()[self.current_line_index + 1]
        if self.current_detail_line_index == 1 then
            data = task.title
        else
            return
        end

        TaskView:show_edit(data, list_bufnr, detail_bufnr)
    end
end

return TaskView
