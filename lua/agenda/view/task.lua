local M = {}

local window_common = require('agenda.window.common')
local task_repository = require('agenda.repository.task_repository')
local window_config = require('agenda.config.window')
local task_service = require('agenda.service.task_service')
local utils = require('agenda.util.common')

local current_line_index = 0
local current_detail_line_index = 0

local list_bufnr = nil
local list_winnr = nil

local detail_bufnr = nil
local detail_winnr = nil

local edit_bufnr = nil
local edit_winnr = nil

---@alias WindowType "list"|"detail"|"edit"

-- @type WindowType
local current_window = "list"

M.render = function()
    M.render_task_list()
    M.render_task_detail()
end

M.render_task_list = function()
    window_common.clean_buffer(M.list_bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = M.list_bufnr })
    for i, task in pairs(task_repository.get_all()) do
        vim.api.nvim_buf_set_lines(M.list_bufnr, i - 1, i, false, { task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = M.list_bufnr })

    M.highlight_list_line(M.list_bufnr)
end

M.render_task_detail = function()
    window_common.clean_buffer(M.detail_bufnr)
    if task_repository.size() == 0 then
        return
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = M.detail_bufnr })
    local task = task_repository.get_all()[current_line_index + 1]
    vim.api.nvim_buf_set_lines(M.detail_bufnr, 0, 1, false, { "Id: " .. task.id })
    vim.api.nvim_buf_set_lines(M.detail_bufnr, 1, 2, false, { "Title: " .. task.title })
    vim.api.nvim_set_option_value('modifiable', false, { buf = M.detail_bufnr })

    M.highlight_list_line(M.list_bufnr)
end

M.highlight_list_line = function(bufnr)
    M.clear_marks(bufnr)

    local task_count = task_repository.size()
    if task_count > 0 then
        local len = #(task_repository.get_all()[current_line_index + 1].title)
        M.highlight_line(bufnr, current_line_index, len)
    end
end

M.highlight_detail_line = function(bufnr)
    M.clear_marks(bufnr)
    local len = #(vim.api.nvim_buf_get_lines(bufnr, current_detail_line_index, current_detail_line_index + 1, false)[1])
    M.highlight_line(bufnr, current_detail_line_index, len)
end

M.highlight_line = function(bufnr, line_index, len)
    vim.api.nvim_buf_set_extmark(bufnr, ns, line_index, 0, { end_col = len, hl_group = "Search" })
end

M.clear_marks = function(bufnr)
    local all = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bufnr, ns, mark[1])
    end
end

M.close = function(winnr, detail_winnr, detail_bufnr)
    if current_window == "detail" then
        M.clear_marks(detail_bufnr)
        current_window = "list"
    elseif current_window == "list" then
        vim.api.nvim_win_close(winnr, true)
        vim.api.nvim_win_close(detail_winnr, true)
    end
end

M.do_action = function(list_bufnr, detail_bufnr)
    if current_window == "list" then
        current_window = "detail"
        current_detail_line_index = 1
        M.highlight_detail_line(detail_bufnr)
    elseif current_window == "detail" then
        local data = ""
        local task = task_repository.get_all()[current_line_index + 1]
        if current_detail_line_index == 1 then
            data = task.title
        else
            return
        end

        M.show_edit(data, list_bufnr, detail_bufnr)
    end
end

return M
