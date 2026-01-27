local M = {}

local window_common = require('agenda.window.common')
local task_repository = require('agenda.repository.task_repository')

local current_line_index = 0

M.open = function()
    local bufnr, winnr = window_common.get_win()

    vim.api.nvim_set_hl(0, "NoCursor", { fg = "#000000", bg = "#000000", blend = 100 })
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})
    window_common.clean_buffer(bufnr)

    task_repository.add({ title = "Task 1" })
    task_repository.add({ title = "Task 2" })

    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    for i, task in pairs(task_repository.get_all()) do
        vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { "- " .. task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    vim.api.nvim_win_set_cursor(winnr, { 1, 0 })

    local ns = vim.api.nvim_create_namespace("agenda")
    vim.keymap.set('n', 'j', function() M.move_down(bufnr, ns) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'k', function() M.move_up(bufnr, ns) end, { buffer = true, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = true, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = true, silent = true })
end

M.move_up = function(bufnr, ns)
    if current_line_index > 0 then
        current_line_index = current_line_index - 1
    end
    M.highlight_line(bufnr, ns)
end

M.move_down = function(bufnr, ns)
    if current_line_index < 1 then
        current_line_index = current_line_index + 1
    end
    M.highlight_line(bufnr, ns)
end

M.highlight_line = function(bufnr, ns)
    M.clear_marks(bufnr, ns)
    vim.api.nvim_buf_set_extmark(bufnr, ns, current_line_index, 0, { end_col = 2, hl_group = "Search" })
end

M.clear_marks = function(bufnr, ns)
    local all = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bufnr, ns, mark[1])
    end
end

return M
