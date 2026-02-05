local TaskController = {}

local constants = require('agenda.constants')
local task_service = require('agenda.service.task_service')
local task_store = require('agenda.model.entity.task_store')
local task_ui_state = require('agenda.model.ui.task_ui_state')
local Task = require('agenda.model.entity.task')
local task_view = require('agenda.view.task')
local render_controller = require('agenda.controller.render')
local project_store = require('agenda.model.entity.project_store')
local project_service = require('agenda.service.project_service')

function TaskController:init()
end

function TaskController:init_view()
    task_service:init_load_tasks()
    project_service:init_load_projects()
    -- Initialize selection if we have tasks
    if task_store:get_task_count() > 0 then
        task_ui_state:set_selected_index(0)
    end
    task_view:init()
    self:bind_mapping()
    render_controller:add_view("status_bar")
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
    vim.keymap.set('n', 'j', function() TaskController:detail_move_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() TaskController:detail_move_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() TaskController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() TaskController:do_action() end,
        { buffer = bufnr, silent = true })
end

---Get currently selected task
---@return Task|nil
function TaskController:get_selected_task()
    local index = task_ui_state:get_selected_index()
    if index == nil then
        return nil
    end
    return task_store:get_task(index + 1)
end

---Get view data for rendering
---@return {tasks: Task[], selected_index: number|nil, active_window: WindowType, detail_index: number|nil, project_name: string|nil}
function TaskController:get_view_data()
    local task = self:get_selected_task()
    local project_name = nil
    if task and task.project_id then
        local project = project_store:get_project_by_id(task.project_id)
        if project then
            project_name = project.name
        end
    end

    return {
        tasks = task_store:get_tasks(),
        selected_index = task_ui_state:get_selected_index(),
        active_window = task_ui_state:get_active_window(),
        detail_index = task_ui_state:get_detail_index(),
        project_name = project_name
    }
end

function TaskController:create_task(title)
    local task = Task.create(title)
    task_service:save_task(task)
    task_store:add_task(task)

    -- Select the newly created task
    local index = task_store:get_task_index(task.id)
    if index ~= nil then
        task_ui_state:set_selected_index(index)
    end

    render_controller:render()
end

function TaskController:move_up()
    local selected = task_ui_state:get_selected_index()
    if selected == nil then
        return
    end

    if task_ui_state:get_active_window() == "list" then
        if selected > 0 then
            task_ui_state:set_selected_index(selected - 1)
        end
    elseif task_ui_state:get_active_window() == "detail" then
        self:detail_move_up()
        return
    end
    render_controller:render()
end

function TaskController:move_down()
    local selected = task_ui_state:get_selected_index()
    if selected == nil then
        return
    end

    if task_ui_state:get_active_window() == "list" then
        local task_count = task_store:get_task_count()
        if selected < task_count - 1 then
            task_ui_state:set_selected_index(selected + 1)
        end
    elseif task_ui_state:get_active_window() == "detail" then
        self:detail_move_down()
        return
    end
    render_controller:render()
end

function TaskController:detail_move_up()
    local detail_index = task_ui_state:get_detail_index()
    if detail_index == nil then
        return
    end

    if detail_index > constants.TITLE_LINE_INDEX then
        task_ui_state:set_detail_index(detail_index - 1)
    end
    render_controller:render()
end

function TaskController:detail_move_down()
    local detail_index = task_ui_state:get_detail_index()
    if detail_index == nil then
        return
    end

    if detail_index < constants.DESCRIPTION_LINE_INDEX then
        task_ui_state:set_detail_index(detail_index + 1)
    end
    render_controller:render()
end

function TaskController:remove_task()
    if task_ui_state:get_active_window() ~= "list" or task_ui_state:get_selected_index() == nil then
        return
    end

    local task = self:get_selected_task()
    if task == nil then
        return
    end

    task_service:delete_task(task)
    task_store:remove_task(task.id)

    -- Adjust selected index if needed
    local task_count = task_store:get_task_count()
    local selected = task_ui_state:get_selected_index()
    if task_count == 0 then
        task_ui_state:set_selected_index(nil)
    elseif selected ~= nil and selected >= task_count then
        task_ui_state:set_selected_index(task_count - 1)
    end

    render_controller:render()
end

function TaskController:show_edit()
    local task = self:get_selected_task()

    if task == nil then
        return
    end

    local detail_index = task_ui_state:get_detail_index()

    if detail_index == constants.TITLE_LINE_INDEX then
        local callback = function(new_value)
            if new_value == nil then
                return
            end

            local current_task = self:get_selected_task()
            if current_task then
                local updated_task = Task.with_title(current_task, new_value)
                task_service:save_task(updated_task)
                task_store:update_task(updated_task)
            end
            render_controller:render()
        end

        render_controller:add_view("input", { callback = callback, data = task.title })
    elseif detail_index == constants.STATE_LINE_INDEX then
        local callback = function(new_value)
            if new_value == nil then
                return
            end

            local current_task = self:get_selected_task()
            if current_task then
                local updated_task = Task.with_status(current_task, new_value)
                task_service:save_task(updated_task)
                task_store:update_task(updated_task)
            end
            render_controller:render()
        end

        render_controller:add_view("input", {
            callback = callback,
            data = Task.get_status_options(),
            mode = "select"
        })
    elseif detail_index == constants.PROJECT_LINE_INDEX then
        local callback = function(new_value)
            if new_value == nil then
                return
            end

            local current_task = self:get_selected_task()
            if current_task then
                -- "None" means remove project assignment
                local project_id = nil
                if new_value ~= "None" then
                    -- Find project by name
                    local projects = project_store:get_projects()
                    for _, project in ipairs(projects) do
                        if project.name == new_value then
                            project_id = project.id
                            break
                        end
                    end
                end
                local updated_task = Task.with_project(current_task, project_id)
                task_service:save_task(updated_task)
                task_store:update_task(updated_task)
            end
            render_controller:render()
        end

        -- Build options list: "None" + all project names
        local options = { "None" }
        local projects = project_store:get_projects()
        for _, project in ipairs(projects) do
            table.insert(options, project.name)
        end

        render_controller:add_view("input", {
            callback = callback,
            data = options,
            mode = "select"
        })
    elseif detail_index == constants.DESCRIPTION_LINE_INDEX then
        local callback = function(new_value)
            if new_value == nil then
                return
            end

            local current_task = self:get_selected_task()
            if current_task then
                local updated_task = Task.with_description(current_task, new_value)
                task_service:save_task(updated_task)
                task_store:update_task(updated_task)
            end
            render_controller:render()
        end

        render_controller:add_view("input", {
            callback = callback,
            data = task.description or "",
            mode = "multiline"
        })
    end
end

function TaskController:close()
    if task_ui_state:get_active_window() == "detail" then
        task_ui_state:set_active_window("list")
        render_controller:render()
        return
    end
    render_controller:remove_view("status_bar", false)
    render_controller:remove_view("task")
end

function TaskController:do_action()
    if task_ui_state:get_selected_index() == nil then
        return
    end

    if task_ui_state:get_active_window() == "list" then
        self:edit_task()
        render_controller:render()
    elseif task_ui_state:get_active_window() == "detail" then
        self:show_edit()
    end
end

function TaskController:edit_task()
    if task_store:get_task_count() == 0 then
        return
    end

    task_ui_state:set_active_window("detail")
    task_ui_state:set_detail_index(constants.TITLE_LINE_INDEX)
end

return TaskController
