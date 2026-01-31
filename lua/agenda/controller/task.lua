local TaskController = {}

local constants = require('agenda.constants')
local task_service = require('agenda.service.task_service')
local app_state = require('agenda.model.app_state')
local Task = require('agenda.model.task')
local task_view = require('agenda.view.task')
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

---Get view data from AppState for rendering
---@return {tasks: Task[], selected_index: number|nil, active_window: WindowType, detail_index: number|nil}
function TaskController:get_view_data()
    return {
        tasks = app_state:get_tasks(),
        selected_index = app_state:get_selected_index(),
        active_window = app_state:get_active_window(),
        detail_index = app_state:get_detail_index()
    }
end

function TaskController:create_task(title)
    local task = Task.create(title)
    task_service:save_task(task)
    app_state:add_task(task)

    -- Select the newly created task
    local index = app_state:get_task_index(task.id)
    if index ~= nil then
        app_state:set_selected_index(index)
    end

    render_controller:render()
end

function TaskController:move_up()
    if app_state:get_selected_index() == nil then
        return
    end

    if app_state:get_active_window() == "list" then
        app_state:move_selection_up()
    end
    render_controller:render()
end

function TaskController:move_down()
    if app_state:get_selected_index() == nil then
        return
    end

    if app_state:get_active_window() == "list" then
        app_state:move_selection_down()
    end
    render_controller:render()
end

function TaskController:remove_task()
    if app_state:get_active_window() ~= "list" or app_state:get_selected_index() == nil then
        return
    end

    local task = app_state:get_selected_task()
    if task == nil then
        return
    end

    task_service:delete_task(task)
    app_state:remove_task(task.id)

    render_controller:render()
end

function TaskController:show_edit()
    local data = ""
    local task = app_state:get_selected_task()

    if task == nil then
        return
    end

    if app_state:get_detail_index() == constants.TITLE_LINE_INDEX then
        data = task.title
    else
        return
    end

    local callback = function(new_value)
        if new_value == nil then
            return
        end

        local current_task = app_state:get_selected_task()
        if current_task then
            local updated_task = Task.with_title(current_task, new_value)
            task_service:save_task(updated_task)
            app_state:update_task(updated_task)
        end
        render_controller:render()
    end

    render_controller:add_view("input", { callback = callback, data = data })
end

function TaskController:close()
    if app_state:get_active_window() == "detail" then
        app_state:set_active_window("list")
        render_controller:render()
        return
    end
    render_controller:remove_view("task")
end

function TaskController:do_action()
    if app_state:get_selected_index() == nil then
        return
    end

    if app_state:get_active_window() == "list" then
        self:edit_task()
        render_controller:render()
    elseif app_state:get_active_window() == "detail" then
        self:show_edit()
    end
end

function TaskController:edit_task()
    if app_state:get_task_count() == 0 then
        return
    end

    app_state:set_active_window("detail")
    app_state:set_detail_index(constants.TITLE_LINE_INDEX)
end

return TaskController
