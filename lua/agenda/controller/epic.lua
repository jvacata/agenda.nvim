local EpicController = {}

local constants = require('agenda.constants')
local epic_service = require('agenda.service.epic_service')
local epic_store = require('agenda.model.entity.epic_store')
local epic_ui_state = require('agenda.model.ui.epic_ui_state')
local Epic = require('agenda.model.entity.epic')
local epic_view = require('agenda.view.epic')
local render_controller = require('agenda.controller.render')
local task_store = require('agenda.model.entity.task_store')
local task_service = require('agenda.service.task_service')
local Task = require('agenda.model.entity.task')

function EpicController:init()
end

function EpicController:init_view()
    epic_service:init_load_epics()
    if epic_store:get_epic_count() > 0 then
        epic_ui_state:set_selected_index(0)
    end
    epic_view:init()
    self:bind_mapping()
    render_controller:add_view("background")
    render_controller:add_view("status_bar")
end

function EpicController:bind_mapping()
    self:bind_list_mapping(epic_view.list_bufnr)
    self:bind_detail_mapping(epic_view.detail_bufnr)
end

function EpicController:bind_list_mapping(bufnr)
    vim.keymap.set('n', 'j', function() EpicController:move_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() EpicController:move_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'a', function() EpicController:create_epic("New epic") end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'dd', function() EpicController:remove_epic() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() EpicController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() EpicController:do_action() end,
        { buffer = bufnr, silent = true })
end

function EpicController:bind_detail_mapping(bufnr)
    vim.keymap.set('n', 'j', function() EpicController:detail_move_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() EpicController:detail_move_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() EpicController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() EpicController:do_action() end,
        { buffer = bufnr, silent = true })
end

---Get currently selected epic
---@return Epic|nil
function EpicController:get_selected_epic()
    local index = epic_ui_state:get_selected_index()
    if index == nil then
        return nil
    end
    return epic_store:get_epic(index + 1)
end

---Get view data for rendering
---@return {epics: Epic[], selected_index: number|nil, active_window: EpicWindowType, detail_index: number|nil, linked_tasks: Task[]}
function EpicController:get_view_data()
    local linked_tasks = {}
    local selected_epic = self:get_selected_epic()
    if selected_epic then
        local tasks = task_store:get_tasks()
        for _, task in ipairs(tasks) do
            if task.epic_id == selected_epic.id then
                table.insert(linked_tasks, task)
            end
        end
    end

    return {
        epics = epic_store:get_epics(),
        selected_index = epic_ui_state:get_selected_index(),
        active_window = epic_ui_state:get_active_window(),
        detail_index = epic_ui_state:get_detail_index(),
        linked_tasks = linked_tasks
    }
end

function EpicController:create_epic(name)
    local epic = Epic.create(name)
    epic_service:save_epic(epic)
    epic_store:add_epic(epic)

    local index = epic_store:get_epic_index(epic.id)
    if index ~= nil then
        epic_ui_state:set_selected_index(index)
    end

    render_controller:render()
end

function EpicController:move_up()
    local selected = epic_ui_state:get_selected_index()
    if selected == nil then
        return
    end

    if epic_ui_state:get_active_window() == "list" then
        if selected > 0 then
            epic_ui_state:set_selected_index(selected - 1)
        end
    elseif epic_ui_state:get_active_window() == "detail" then
        self:detail_move_up()
        return
    end
    render_controller:render()
end

function EpicController:move_down()
    local selected = epic_ui_state:get_selected_index()
    if selected == nil then
        return
    end

    if epic_ui_state:get_active_window() == "list" then
        local epic_count = epic_store:get_epic_count()
        if selected < epic_count - 1 then
            epic_ui_state:set_selected_index(selected + 1)
        end
    elseif epic_ui_state:get_active_window() == "detail" then
        self:detail_move_down()
        return
    end
    render_controller:render()
end

function EpicController:detail_move_up()
    local detail_index = epic_ui_state:get_detail_index()
    if detail_index == nil then
        return
    end

    if detail_index > constants.EPIC_NAME_LINE_INDEX then
        epic_ui_state:set_detail_index(detail_index - 1)
    end
    render_controller:render()
end

function EpicController:detail_move_down()
    local detail_index = epic_ui_state:get_detail_index()
    if detail_index == nil then
        return
    end

    if detail_index < constants.EPIC_DESCRIPTION_LINE_INDEX then
        epic_ui_state:set_detail_index(detail_index + 1)
    end
    render_controller:render()
end

function EpicController:remove_epic()
    if epic_ui_state:get_active_window() ~= "list" or epic_ui_state:get_selected_index() == nil then
        return
    end

    local epic = self:get_selected_epic()
    if epic == nil then
        return
    end

    epic_service:delete_epic(epic)
    epic_store:remove_epic(epic.id)

    -- Clear epic_id from all linked tasks
    local tasks = task_store:get_tasks()
    for _, task in ipairs(tasks) do
        if task.epic_id == epic.id then
            local updated_task = Task.with_epic(task, nil)
            task_service:save_task(updated_task)
            task_store:update_task(updated_task)
        end
    end

    -- Adjust selected index if needed
    local epic_count = epic_store:get_epic_count()
    local selected = epic_ui_state:get_selected_index()
    if epic_count == 0 then
        epic_ui_state:set_selected_index(nil)
    elseif selected ~= nil and selected >= epic_count then
        epic_ui_state:set_selected_index(epic_count - 1)
    end

    render_controller:render()
end

function EpicController:show_edit()
    local epic = self:get_selected_epic()

    if epic == nil then
        return
    end

    local detail_index = epic_ui_state:get_detail_index()

    if detail_index == constants.EPIC_NAME_LINE_INDEX then
        local callback = function(new_value)
            if new_value == nil then
                return
            end

            local current_epic = self:get_selected_epic()
            if current_epic then
                local updated_epic = Epic.with_name(current_epic, new_value)
                epic_service:save_epic(updated_epic)
                epic_store:update_epic(updated_epic)
            end
            render_controller:render()
        end

        render_controller:add_view("input", { callback = callback, data = epic.name })
    elseif detail_index == constants.EPIC_DESCRIPTION_LINE_INDEX then
        local callback = function(new_value)
            if new_value == nil then
                return
            end

            local current_epic = self:get_selected_epic()
            if current_epic then
                local updated_epic = Epic.with_description(current_epic, new_value)
                epic_service:save_epic(updated_epic)
                epic_store:update_epic(updated_epic)
            end
            render_controller:render()
        end

        render_controller:add_view("input", {
            callback = callback,
            data = epic.description or "",
            mode = "multiline"
        })
    end
end

function EpicController:close()
    if epic_ui_state:get_active_window() == "detail" then
        epic_ui_state:set_active_window("list")
        render_controller:render()
        return
    end
    render_controller:remove_view("status_bar", false)
    render_controller:remove_view("background", false)
    render_controller:remove_view("epic")
end

function EpicController:do_action()
    if epic_ui_state:get_selected_index() == nil then
        return
    end

    if epic_ui_state:get_active_window() == "list" then
        self:edit_epic()
        render_controller:render()
    elseif epic_ui_state:get_active_window() == "detail" then
        self:show_edit()
    end
end

function EpicController:edit_epic()
    if epic_store:get_epic_count() == 0 then
        return
    end

    epic_ui_state:set_active_window("detail")
    epic_ui_state:set_detail_index(constants.EPIC_NAME_LINE_INDEX)
end

return EpicController
