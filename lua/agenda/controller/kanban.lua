local KanbanController = {}

local task_service = require('agenda.service.task_service')
local kanban_store = require('agenda.model.entity.kanban_store')
local kanban_ui_state = require('agenda.model.ui.kanban_ui_state')
local kanban_view = require('agenda.view.kanban')
local render_controller = require('agenda.controller.render')

function KanbanController:init()
end

function KanbanController:init_view()
    task_service:init_load_tasks()

    -- Load tasks into kanban store distributed by status
    local task_store = require('agenda.model.entity.task_store')
    local tasks = task_store:get_tasks()
    kanban_store:init_with_tasks(tasks)

    -- Initialize selection to first task in current column
    local selected_column = kanban_ui_state:get_selected_column()
    if kanban_store:get_task_count(selected_column) > 0 then
        kanban_ui_state:set_selected_row(0)
    else
        kanban_ui_state:set_selected_row(nil)
    end

    kanban_view:init()
    self:bind_mapping()
end

function KanbanController:bind_mapping()
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
    vim.keymap.set('n', 'q', function() KanbanController:close() end,
        { buffer = bufnr, silent = true })
end

---Get view data for rendering
---@return {columns: table<string, Task[]>, column_names: string[], column_titles: table<string, string>, selected_column: string, selected_row: number|nil}
function KanbanController:get_view_data()
    local column_names = kanban_store:get_column_names()
    local column_titles = {}
    for _, name in ipairs(column_names) do
        column_titles[name] = kanban_store:get_column_title(name)
    end

    return {
        columns = kanban_store:get_all_columns(),
        column_names = column_names,
        column_titles = column_titles,
        selected_column = kanban_ui_state:get_selected_column(),
        selected_row = kanban_ui_state:get_selected_row()
    }
end

function KanbanController:move_down()
    local selected_row = kanban_ui_state:get_selected_row()
    local selected_column = kanban_ui_state:get_selected_column()

    if selected_row == nil then
        -- Try to select first item in current column
        if kanban_store:get_task_count(selected_column) > 0 then
            kanban_ui_state:set_selected_row(0)
        end
    else
        local task_count = kanban_store:get_task_count(selected_column)
        if selected_row < task_count - 1 then
            kanban_ui_state:set_selected_row(selected_row + 1)
        end
    end

    render_controller:render()
end

function KanbanController:move_up()
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
        local task_count = kanban_store:get_task_count(new_column)
        local selected_row = kanban_ui_state:get_selected_row()
        if task_count == 0 then
            kanban_ui_state:set_selected_row(nil)
        elseif selected_row == nil then
            kanban_ui_state:set_selected_row(0)
        elseif selected_row >= task_count then
            kanban_ui_state:set_selected_row(task_count - 1)
        end
    end

    render_controller:render()
end

function KanbanController:move_right()
    local column_names = kanban_store:get_column_names()
    local current_column = kanban_ui_state:get_selected_column()

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
        local task_count = kanban_store:get_task_count(new_column)
        local selected_row = kanban_ui_state:get_selected_row()
        if task_count == 0 then
            kanban_ui_state:set_selected_row(nil)
        elseif selected_row == nil then
            kanban_ui_state:set_selected_row(0)
        elseif selected_row >= task_count then
            kanban_ui_state:set_selected_row(task_count - 1)
        end
    end

    render_controller:render()
end

function KanbanController:close()
    render_controller:remove_view("kanban")
end

return KanbanController
