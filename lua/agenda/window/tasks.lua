local M = {}

local window_common = require('agenda.window.common')
local task_repository = require('agenda.repository.task_repository')
local window_config = require('agenda.config.window')

local current_line_index = 0
local current_detail_line_index = 0

---@alias WindowType "list"|"detail"|"edit"

-- @type WindowType
local current_window = "list"

local ns = vim.api.nvim_create_namespace("agenda")

M.open = function()
    local bufnr, winnr = window_common.get_win("agenda_task_list", window_config.task_list_window())
    local detail_bufnr, detail_winnr = window_common.get_win("agenda_task_detail", window_config.task_detail_window())
    M.set_task_window_mapping(bufnr, detail_bufnr, winnr, detail_winnr)
    M.draw_task_list(bufnr)
    M.draw_task_detail(detail_bufnr)
end

M.set_task_window_mapping = function(bufnr, detail_bufnr, winnr, detail_winnr)
    vim.keymap.set('n', 'j', function() M.move_down(bufnr, detail_bufnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'k', function() M.move_up(bufnr, detail_bufnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'a', function() M.create_task("New task", bufnr, detail_bufnr) end,
        { buffer = true, silent = true })
    vim.keymap.set('n', 'dd', function() M.remove_task(bufnr, detail_bufnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'q', function() M.close(winnr, detail_winnr, detail_bufnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', '<CR>', function() M.do_action(bufnr, detail_bufnr) end, { buffer = true, silent = true })
end

M.draw_task_list = function(bufnr)
    window_common.clean_buffer(bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    for i, task in pairs(task_repository.get_all()) do
        vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    M.highlight_list_line(bufnr)
end

M.draw_task_detail = function(bufnr)
    if task_repository.size() == 0 then
        return
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    local task = task_repository.get_all()[current_line_index + 1]
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { "Title: " .. task.title })
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
end

M.move_up = function(bufnr, detail_bufnr)
    if current_window == "list" then
        if current_line_index > 0 then
            current_line_index = current_line_index - 1
        end
        M.highlight_list_line(bufnr)
        M.draw_task_detail(detail_bufnr)
    end
end

M.move_down = function(bufnr, detail_bufnr)
    if current_window == "list" then
        if current_line_index < task_repository.size() - 1 then
            current_line_index = current_line_index + 1
        end
        M.highlight_list_line(bufnr)
        M.draw_task_detail(detail_bufnr)
    end
end

M.create_task = function(title, bufnr, detail_bufnr)
    task_repository.add({ title = title })
    M.draw_task_list(bufnr)
    M.draw_task_detail(detail_bufnr)
end

M.remove_task = function(bufnr, detail_bufnr)
    task_repository.remove(task_repository.get_all()[current_line_index + 1])
    local task_count = task_repository.size()
    if current_line_index >= task_count then
        current_line_index = task_count - 1
    end

    M.draw_task_list(bufnr)
    M.draw_task_detail(detail_bufnr)
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
        M.highlight_detail_line(detail_bufnr)
    elseif current_window == "detail" then
        local data = ""
        local task = task_repository.get_all()[current_line_index + 1]
        if current_detail_line_index == 0 then
            data = task.title
        else
            return
        end

        M.show_edit(data, list_bufnr, detail_bufnr)
    end
end

M.show_edit = function(data, list_bufnr, detail_bufnr)
    local edit_bufnr, edit_winnr = window_common.get_win("agenda_task_edit", window_config.task_edit_window())
    window_common.clean_buffer(edit_bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = edit_bufnr })
    vim.api.nvim_buf_set_lines(edit_bufnr, 0, 1, false, { data })
    M.set_edit_window_mapping(edit_bufnr, edit_winnr, list_bufnr, detail_bufnr)
    vim.api.nvim_set_option_value('guicursor',
        'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor', {})
end

M.set_edit_window_mapping = function(bufnr, winnr, list_bufnr, detail_bufnr)
    vim.keymap.set('n', 'q', function() M.cancel_edit(winnr) end,
        { buffer = true, silent = true })
    vim.keymap.set('n', '<CR>', function() M.close_edit(winnr, bufnr, list_bufnr, detail_bufnr) end,
        { buffer = true, silent = true })
end

M.cancel_edit = function(winnr)
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})
    vim.api.nvim_win_close(winnr, true)
end

M.close_edit = function(winnr, bufnr, list_bufnr, detail_bufnr)
    local value = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
    local task = task_repository.get_all()[current_line_index + 1]
    task.title = value

    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})
    vim.api.nvim_win_close(winnr, true)

    M.draw_task_list(list_bufnr)
    M.draw_task_detail(detail_bufnr)
    M.highlight_detail_line(detail_bufnr)
end

return M
