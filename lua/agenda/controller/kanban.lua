local KanbanController = {}

local task_service = require('agenda.service.task_service')
local project_service = require('agenda.service.project_service')
local kanban_store = require('agenda.model.entity.kanban_store')
local kanban_ui_state = require('agenda.model.ui.kanban_ui_state')
local kanban_view = require('agenda.view.kanban')
local render_controller = require('agenda.controller.render')
local project_store = require('agenda.model.entity.project_store')
local task_store = require('agenda.model.entity.task_store')
local Task = require('agenda.model.entity.task')

function KanbanController:init()
end

function KanbanController:init_view()
    task_service:init_load_tasks()
    project_service:init_load_projects()

    -- Load tasks into kanban store distributed by status
    local tasks = task_store:get_tasks()
    kanban_store:init_with_tasks(tasks)

    -- Initialize project selection (start at "Unlisted" which is index 0)
    kanban_ui_state:set_project_list_index(0)
    kanban_ui_state:set_selected_project_id(nil) -- nil = Unlisted
    kanban_ui_state:set_focus("project_list")

    -- Initialize selection to first task in current column for selected project
    self:update_row_selection()

    kanban_view:init()
    self:bind_mapping()
    render_controller:add_view("background")
    render_controller:add_view("status_bar")
end

function KanbanController:bind_mapping()
    -- Board keymaps
    local bufnr = kanban_view.bufnr

    vim.keymap.set('n', 'j', function() KanbanController:move_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() KanbanController:move_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', function() KanbanController:move_left() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', function() KanbanController:move_right() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() KanbanController:handle_enter() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() KanbanController:handle_q() end,
        { buffer = bufnr, silent = true })

    -- Project panel keymaps
    local project_bufnr = kanban_view.project_bufnr

    vim.keymap.set('n', 'j', function() KanbanController:project_move_down() end,
        { buffer = project_bufnr, silent = true })
    vim.keymap.set('n', 'k', function() KanbanController:project_move_up() end,
        { buffer = project_bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = project_bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = project_bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = project_bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() KanbanController:project_enter() end,
        { buffer = project_bufnr, silent = true })
    vim.keymap.set('n', 'q', function() KanbanController:close() end,
        { buffer = project_bufnr, silent = true })
end

---Build the project list for display
---@return string[]
function KanbanController:build_project_list()
    local list = { "Unlisted" }
    local projects = project_store:get_projects()
    for _, project in ipairs(projects) do
        table.insert(list, project.name)
    end
    return list
end

---Get project ID for a given project list index
---@param index number (0-based)
---@return string|nil -- nil for "Unlisted"
function KanbanController:get_project_id_for_index(index)
    if index == 0 then
        return nil -- Unlisted
    end
    local projects = project_store:get_projects()
    local project = projects[index] -- index is 1-based for projects array (since 0 is Unlisted)
    if project then
        return project.id
    end
    return nil
end

---Get view data for rendering
---@return {columns: table<string, Task[]>, column_names: string[], column_titles: table<string, string>, selected_column: string, selected_row: number|nil, project_list: string[], project_list_index: number, focus: string}
function KanbanController:get_view_data()
    local column_names = kanban_store:get_column_names()
    local column_titles = {}
    for _, name in ipairs(column_names) do
        column_titles[name] = kanban_store:get_column_title(name)
    end

    local selected_project_id = kanban_ui_state:get_selected_project_id()
    local columns = kanban_store:get_columns_by_project(selected_project_id)

    -- When moving, relocate the task from its source column to the selected column
    local moving_task_id = kanban_ui_state:get_moving_task_id()
    if moving_task_id then
        local selected_column = kanban_ui_state:get_selected_column()
        local moving_task = nil
        for _, col_name in ipairs(column_names) do
            local tasks = columns[col_name]
            for i, t in ipairs(tasks) do
                if t.id == moving_task_id then
                    moving_task = t
                    table.remove(tasks, i)
                    break
                end
            end
            if moving_task then break end
        end
        if moving_task then
            table.insert(columns[selected_column], moving_task)
        end
    end

    return {
        columns = columns,
        column_names = column_names,
        column_titles = column_titles,
        selected_column = kanban_ui_state:get_selected_column(),
        selected_row = kanban_ui_state:get_selected_row(),
        moving_task_id = kanban_ui_state:get_moving_task_id(),
        project_list = self:build_project_list(),
        project_list_index = kanban_ui_state:get_project_list_index(),
        focus = kanban_ui_state:get_focus()
    }
end

function KanbanController:move_down()
    if kanban_ui_state:get_moving_task_id() then
        return
    end

    local selected_row = kanban_ui_state:get_selected_row()
    local selected_column = kanban_ui_state:get_selected_column()
    local selected_project_id = kanban_ui_state:get_selected_project_id()

    if selected_row == nil then
        -- Try to select first item in current column
        if kanban_store:get_task_count_by_project(selected_column, selected_project_id) > 0 then
            kanban_ui_state:set_selected_row(0)
        end
    else
        local task_count = kanban_store:get_task_count_by_project(selected_column, selected_project_id)
        if selected_row < task_count - 1 then
            kanban_ui_state:set_selected_row(selected_row + 1)
        end
    end

    render_controller:render()
end

function KanbanController:move_up()
    if kanban_ui_state:get_moving_task_id() then
        return
    end

    local selected_row = kanban_ui_state:get_selected_row()
    if selected_row == nil then
        return
    end

    if selected_row > 0 then
        kanban_ui_state:set_selected_row(selected_row - 1)
    end

    render_controller:render()
end

function KanbanController:move_left()
    local column_names = kanban_store:get_column_names()
    local current_column = kanban_ui_state:get_selected_column()
    local selected_project_id = kanban_ui_state:get_selected_project_id()

    -- Find current column index
    local current_index = 1
    for i, name in ipairs(column_names) do
        if name == current_column then
            current_index = i
            break
        end
    end

    -- Move to previous column if possible
    if current_index > 1 then
        local new_column = column_names[current_index - 1]
        kanban_ui_state:set_selected_column(new_column)

        -- Adjust row selection for new column
        local moving_task_id = kanban_ui_state:get_moving_task_id()
        if moving_task_id then
            -- Moving task will be appended to target column; select it
            kanban_ui_state:set_selected_row(self:get_effective_task_count(new_column, selected_project_id,
                moving_task_id) - 1)
        else
            local task_count = kanban_store:get_task_count_by_project(new_column, selected_project_id)
            local selected_row = kanban_ui_state:get_selected_row()
            if task_count == 0 then
                kanban_ui_state:set_selected_row(nil)
            elseif selected_row == nil then
                kanban_ui_state:set_selected_row(0)
            elseif selected_row >= task_count then
                kanban_ui_state:set_selected_row(task_count - 1)
            end
        end
    end

    render_controller:render()
end

function KanbanController:move_right()
    local column_names = kanban_store:get_column_names()
    local current_column = kanban_ui_state:get_selected_column()
    local selected_project_id = kanban_ui_state:get_selected_project_id()

    -- Find current column index
    local current_index = 1
    for i, name in ipairs(column_names) do
        if name == current_column then
            current_index = i
            break
        end
    end

    -- Move to next column if possible
    if current_index < #column_names then
        local new_column = column_names[current_index + 1]
        kanban_ui_state:set_selected_column(new_column)

        -- Adjust row selection for new column
        local moving_task_id = kanban_ui_state:get_moving_task_id()
        if moving_task_id then
            -- Moving task will be appended to target column; select it
            kanban_ui_state:set_selected_row(self:get_effective_task_count(new_column, selected_project_id,
                moving_task_id) - 1)
        else
            local task_count = kanban_store:get_task_count_by_project(new_column, selected_project_id)
            local selected_row = kanban_ui_state:get_selected_row()
            if task_count == 0 then
                kanban_ui_state:set_selected_row(nil)
            elseif selected_row == nil then
                kanban_ui_state:set_selected_row(0)
            elseif selected_row >= task_count then
                kanban_ui_state:set_selected_row(task_count - 1)
            end
        end
    end

    render_controller:render()
end

---Get the effective task count for a column when a task is being moved
---@param column KanbanColumn
---@param project_id string|nil
---@param moving_task_id string
---@return number
function KanbanController:get_effective_task_count(column, project_id, moving_task_id)
    local store_count = kanban_store:get_task_count_by_project(column, project_id)
    -- Check if the moving task's source column is this column
    local all_tasks = task_store:get_tasks()
    for _, t in ipairs(all_tasks) do
        if t.id == moving_task_id then
            local source_column = kanban_store:status_to_column(t.status)
            if source_column == column then
                return store_count     -- removed and re-added, same count
            else
                return store_count + 1 -- added from elsewhere
            end
        end
    end
    return store_count
end

---Handle enter key - pick up or drop a task
function KanbanController:handle_enter()
    local moving_task_id = kanban_ui_state:get_moving_task_id()

    if moving_task_id == nil then
        -- Pick up: start moving the selected task
        local selected_row = kanban_ui_state:get_selected_row()
        if selected_row == nil then
            return
        end

        local selected_column = kanban_ui_state:get_selected_column()
        local selected_project_id = kanban_ui_state:get_selected_project_id()
        local task = kanban_store:get_task_by_project(selected_column, selected_row + 1, selected_project_id)
        if task then
            kanban_ui_state:set_moving_task_id(task.id)
            render_controller:render()
        end
    else
        -- Drop: move task to current column
        local target_column = kanban_ui_state:get_selected_column()
        local new_status = kanban_store:column_to_status(target_column)
        local selected_project_id = kanban_ui_state:get_selected_project_id()

        -- Find the task being moved
        local all_tasks = task_store:get_tasks()
        local moving_task = nil
        for _, t in ipairs(all_tasks) do
            if t.id == moving_task_id then
                moving_task = t
                break
            end
        end

        if moving_task == nil then
            kanban_ui_state:set_moving_task_id(nil)
            render_controller:render()
            return
        end

        -- Update status if changed
        if moving_task.status ~= new_status then
            local updated_task = Task.with_status(moving_task, new_status)
            task_service:save_task(updated_task)
            task_store:update_task(updated_task)
            kanban_store:init_with_tasks(task_store:get_tasks())
        end

        -- Clear moving state and adjust selection
        kanban_ui_state:set_moving_task_id(nil)
        local task_count = kanban_store:get_task_count_by_project(target_column, selected_project_id)
        local selected_row = kanban_ui_state:get_selected_row()
        if task_count == 0 then
            kanban_ui_state:set_selected_row(nil)
        elseif selected_row ~= nil and selected_row >= task_count then
            kanban_ui_state:set_selected_row(task_count - 1)
        elseif selected_row == nil and task_count > 0 then
            kanban_ui_state:set_selected_row(0)
        end

        render_controller:render()
    end
end

---Handle q key - cancel move, switch focus, or close
function KanbanController:handle_q()
    local focus = kanban_ui_state:get_focus()
    if focus == "board" then
        local moving_task_id = kanban_ui_state:get_moving_task_id()
        if moving_task_id ~= nil then
            -- Cancel move: restore selection to the task's actual column
            kanban_ui_state:set_moving_task_id(nil)
            local selected_project_id = kanban_ui_state:get_selected_project_id()
            local all_tasks = task_store:get_tasks()
            for _, t in ipairs(all_tasks) do
                if t.id == moving_task_id then
                    local source_column = kanban_store:status_to_column(t.status)
                    kanban_ui_state:set_selected_column(source_column)
                    local tasks = kanban_store:get_tasks_by_project(source_column, selected_project_id)
                    for ri, pt in ipairs(tasks) do
                        if pt.id == moving_task_id then
                            kanban_ui_state:set_selected_row(ri - 1)
                            break
                        end
                    end
                    break
                end
            end
            render_controller:render()
        else
            -- Switch back to project list
            kanban_ui_state:set_focus("project_list")
            vim.api.nvim_set_current_win(kanban_view.project_winnr)
            render_controller:render()
        end
    else
        self:close()
    end
end

---Move up in project list
function KanbanController:project_move_up()
    local index = kanban_ui_state:get_project_list_index()
    if index > 0 then
        kanban_ui_state:set_project_list_index(index - 1)
        self:update_selected_project()
    end
    render_controller:render()
end

---Move down in project list
function KanbanController:project_move_down()
    local index = kanban_ui_state:get_project_list_index()
    local project_list = self:build_project_list()
    if index < #project_list - 1 then
        kanban_ui_state:set_project_list_index(index + 1)
        self:update_selected_project()
    end
    render_controller:render()
end

---Enter from project list to board
function KanbanController:project_enter()
    kanban_ui_state:set_focus("board")
    vim.api.nvim_set_current_win(kanban_view.winnr)
    render_controller:render()
end

---Update selected project based on current project list index
function KanbanController:update_selected_project()
    local index = kanban_ui_state:get_project_list_index()
    local project_id = self:get_project_id_for_index(index)
    kanban_ui_state:set_selected_project_id(project_id)
    self:update_row_selection()
end

---Update row selection based on current column and project
function KanbanController:update_row_selection()
    local selected_column = kanban_ui_state:get_selected_column()
    local selected_project_id = kanban_ui_state:get_selected_project_id()
    local task_count = kanban_store:get_task_count_by_project(selected_column, selected_project_id)

    if task_count > 0 then
        kanban_ui_state:set_selected_row(0)
    else
        kanban_ui_state:set_selected_row(nil)
    end
end

function KanbanController:close()
    render_controller:remove_view("status_bar", false)
    render_controller:remove_view("background", false)
    render_controller:remove_view("kanban")
end

return KanbanController
