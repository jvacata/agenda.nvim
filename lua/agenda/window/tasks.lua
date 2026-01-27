local M = {}

local window_common = require('agenda.window.common')
local task_repository = require('agenda.repository.task_repository')

local current_line_index = 0

local ns = vim.api.nvim_create_namespace("agenda")

M.open = function()
    local bufnr, winnr = window_common.get_win()

    vim.api.nvim_set_hl(0, "NoCursor", { fg = "#000000", bg = "#000000", blend = 100 })
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})

    M.draw_task_list(bufnr)

    vim.api.nvim_win_set_cursor(winnr, { 1, 0 })

    vim.keymap.set('n', 'j', function() M.move_down(bufnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'k', function() M.move_up(bufnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'q', function() M.close(winnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'a', function() M.create_task("New task", bufnr) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'dd', function() M.remove_task(bufnr) end, { buffer = true, silent = true })
end

M.draw_task_list = function(bufnr)
    window_common.clean_buffer(bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    for i, task in pairs(task_repository.get_all()) do
        vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { "- " .. task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    M.highlight_line(bufnr)
end

M.move_up = function(bufnr)
    if current_line_index > 0 then
        current_line_index = current_line_index - 1
    end
    M.highlight_line(bufnr)
end

M.move_down = function(bufnr)
    if current_line_index < task_repository.size() - 1 then
        current_line_index = current_line_index + 1
    end
    M.highlight_line(bufnr)
end

M.create_task = function(title, bufnr)
    task_repository.add({ title = title })
    M.draw_task_list(bufnr)
end

M.remove_task = function(bufnr)
    task_repository.remove(task_repository.get_all()[current_line_index + 1])
    M.draw_task_list(bufnr)
end

M.highlight_line = function(bufnr)
    M.clear_marks(bufnr)
    if task_repository.size() > 0 then
        vim.api.nvim_buf_set_extmark(bufnr, ns, current_line_index, 0, { end_col = 2, hl_group = "Search" })
    end
end

M.clear_marks = function(bufnr)
    local all = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bufnr, ns, mark[1])
    end
end

M.close = function(winnr)
    vim.api.nvim_win_close(winnr, true)
end

return M
