local TaskController = {}

local constants = require('agenda.constants')
local task_service = require('agenda.service.task_service')
local task_repository = require('agenda.repository.task_repository')
local task_view = require('agenda.view.task')
local common_util = require('agenda.util.common')
local render_controller = require('agenda.controller.render')

function TaskController:init()
end

function TaskController:init_view()
    task_service:init_load_tasks()
    task_view:init()
    self:bind_mapping()
end

function TaskController:bind_mapping()
    self:bind_list_mapping(task_view.list_bufnr)
    self:bind_detail_mapping(task_view.detail_bufnr)
end

function TaskController:bind_list_mapping(bufnr)
    vim.keymap.set('n', 'j', function() TaskController:move_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() TaskController:move_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'a', function() TaskController:create_task("New task") end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'dd', function() TaskController:remove_task() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() TaskController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() TaskController:do_action() end,
        { buffer = bufnr, silent = true })
end

function TaskController:bind_detail_mapping(bufnr)
    vim.keymap.set('n', 'j', '<Nop>',
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() TaskController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() TaskController:do_action() end,
        { buffer = bufnr, silent = true })
end

function TaskController:create_task(title)
    local task = {
        id = common_util:generate_uuid_v4(),
        title = title,
    }
    task_service:update_task(task)

    if task_view.current_line_index == nil then
        task_view.current_line_index = 0
    end

    render_controller:render()
end

function TaskController:move_up()
    if task_view.current_line_index == nil then
        return
    end

    if task_view.current_window == "list" then
        if task_view.current_line_index > 0 then
            task_view.current_line_index = task_view.current_line_index - 1
        end
    end
    render_controller:render()
end

function TaskController:move_down()
    if task_view.current_line_index == nil then
        return
    end

    if task_view.current_window == "list" then
        if task_view.current_line_index < task_repository:size() - 1 then
            task_view.current_line_index = task_view.current_line_index + 1
        end
    end
    render_controller:render()
end

function TaskController:remove_task()
    if task_view.current_window ~= "list" or task_view.current_line_index == nil then
        return
    end

    local task = task_service:get_current_selected_task(task_view.current_line_index)
    if task == nil then
        return
    end

    task_service:delete_task(task)
    local task_count = task_repository:size()

    if task_count == 0 then
        task_view.current_line_index = nil
    elseif task_view.current_line_index >= task_count then
        task_view.current_line_index = task_count - 1
    end

    render_controller:render()
end

function TaskController:show_edit()
    local data = ""
    local task = task_service:get_current_selected_task(task_view.current_line_index)

    if task == nil then
        return
    end

    if task_view.current_detail_line_index == constants.TITLE_LINE_INDEX then
        data = task.title
    else
        return
    end

    local callback = function(new_value)
        if new_value == nil then
            return
        end

        local task = task_service:get_current_selected_task(task_view.current_line_index)
        task.title = new_value
        task_service:update_task(task)
        render_controller:render()
    end

    render_controller:add_view("input", { callback = callback, data = data })
end

function TaskController:close()
    if task_view.current_window == "detail" then
        task_view.current_window = "list"
        render_controller:render()
        return
    end
    render_controller:remove_view("task")
end

function TaskController:do_action()
    if task_view.current_line_index == nil then
        return
    end

    if task_view.current_window == "list" then
        self:edit_task()
        render_controller:render()
    elseif task_view.current_window == "detail" then
        self:show_edit()
    end
end

function TaskController:edit_task()
    if task_repository:size() == 0 then
        return
    end

    task_view.current_window = "detail"
    task_view.current_detail_line_index = constants.TITLE_LINE_INDEX
end

return TaskController
