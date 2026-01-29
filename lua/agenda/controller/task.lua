local TaskController = {}

local task_service = require('agenda.service.task_service')
local task_repository = require('agenda.repository.task_repository')
local task_view = require('agenda.view.task')
local common_util = require('agenda.util.common')
local input_controller = require('agenda.controller.input')

function TaskController:init()
    task_service:init_load_tasks()
end

function TaskController:bind_mapping()
    self.bind_mapping_buffer(task_view.list_bufnr)
    self.bind_mapping_buffer(task_view.detail_bufnr)
end

function TaskController:bind_mapping_buffer(bufnr)
    vim.keymap.set('n', 'j', function() TaskController:move_down(bufnr, detail_bufnr) end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() TaskController:move_up(bufnr, detail_bufnr) end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'a', function() TaskController:create_task("New task") end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'dd', function() TaskController:remove_task(bufnr, detail_bufnr) end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() TaskController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() TaskController:do_action(bufnr, detail_bufnr) end,
        { buffer = bufnr, silent = true })
end

function TaskController:create_task(title)
    local task = {
        id = common_util.generate_id(),
        title = title,
    }
    task_service.update_task(task)
    task_view.render()
end

function TaskController:move_up(bufnr, detail_bufnr)
    if task_view.current_window == "list" then
        if task_view.current_line_index > 0 then
            task_view.current_line_index = task_view.current_line_index - 1
        end
        TaskController:highlight_list_line(bufnr)
        TaskController:draw_task_detail(detail_bufnr)
    end
end

function TaskController:move_down(bufnr, detail_bufnr)
    if task_view.current_window == "list" then
        if task_view.current_line_index < task_repository.size() - 1 then
            task_view.current_line_index = task_view.current_line_index + 1
        end
        TaskController:highlight_list_line(bufnr)
        TaskController:draw_task_detail(detail_bufnr)
    end
end

function TaskController:remove_task(bufnr, detail_bufnr)
    task_service.delete_task(task_repository.get_all()[task_view.current_line_index + 1])
    local task_count = task_repository.size()
    if task_view.current_line_index >= task_count then
        task_view.current_line_index = task_count - 1
    end

    TaskController:draw_task_list(bufnr)
    TaskController:draw_task_detail(detail_bufnr)
end

function TaskController:show_edit()
    local callback = function(new_value)
        local task = task_repository.get_all()[task_view.current_line_index + 1]
        task.title = new_value
        task_service.update_task(task)
        task_view.render()
    end

    input_controller:initialize(callback)
end

function TaskController:close()
    task_view:close()
end

return TaskController
