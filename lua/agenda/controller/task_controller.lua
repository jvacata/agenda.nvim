local M = {}

local task_service = require('agenda.service.task_service')
local task_repository = require('agenda.repository.task_repository')
local task_view = require('agenda.view.task')
local window_util = require('agenda.util.window')
local input_controller = require('agenda.controller.input_controller')

M.initialize = function()
    task_service.init_load_tasks()

    local bufnr, winnr = window_util.get_win("agenda_task_list", window_util.task_list_window())
    local detail_bufnr, detail_winnr = window_util.get_win("agenda_task_detail", window_util.task_detail_window())
    M.set_mapping(bufnr, detail_bufnr, winnr, detail_winnr)
    M.draw_task_list(bufnr)
    M.draw_task_detail(detail_bufnr)
end

M.set_mapping = function(bufnr, detail_bufnr, winnr, detail_winnr)
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

M.create_task = function()
    task_service.update_task()
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
    local task = { id = utils.generate_uuid_v4(), title = title }
    task_service.update_task(task)
    M.draw_task_list(bufnr)
    M.draw_task_detail(detail_bufnr)
end

M.remove_task = function(bufnr, detail_bufnr)
    task_service.delete_task(task_repository.get_all()[current_line_index + 1])
    local task_count = task_repository.size()
    if current_line_index >= task_count then
        current_line_index = task_count - 1
    end

    M.draw_task_list(bufnr)
    M.draw_task_detail(detail_bufnr)
end

M.show_edit = function()
    local callback = function(new_value)
        local task = task_repository.get_all()[current_line_index + 1]
        task.title = new_value
        task_service.update_task(task)
        task_view.render()
    end

    input_controller.initialize(callback)
end

return M
