local ProjectController = {}

local constants = require('agenda.constants')
local project_service = require('agenda.service.project_service')
local project_store = require('agenda.model.entity.project_store')
local project_ui_state = require('agenda.model.ui.project_ui_state')
local Project = require('agenda.model.entity.project')
local project_view = require('agenda.view.project')
local render_controller = require('agenda.controller.render')

function ProjectController:init()
end

function ProjectController:init_view()
    project_service:init_load_projects()
    -- Initialize selection if we have projects
    if project_store:get_project_count() > 0 then
        project_ui_state:set_selected_index(0)
    end
    project_view:init()
    self:bind_mapping()
    render_controller:add_view("status_bar")
end

function ProjectController:bind_mapping()
    self:bind_list_mapping(project_view.list_bufnr)
    self:bind_detail_mapping(project_view.detail_bufnr)
end

function ProjectController:bind_list_mapping(bufnr)
    vim.keymap.set('n', 'j', function() ProjectController:move_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() ProjectController:move_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'a', function() ProjectController:create_project("New project") end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'dd', function() ProjectController:remove_project() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() ProjectController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() ProjectController:do_action() end,
        { buffer = bufnr, silent = true })
end

function ProjectController:bind_detail_mapping(bufnr)
    vim.keymap.set('n', 'j', function() ProjectController:detail_move_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'h', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() ProjectController:detail_move_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() ProjectController:close() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() ProjectController:do_action() end,
        { buffer = bufnr, silent = true })
end

---Get currently selected project
---@return Project|nil
function ProjectController:get_selected_project()
    local index = project_ui_state:get_selected_index()
    if index == nil then
        return nil
    end
    return project_store:get_project(index + 1)
end

---Get view data for rendering
---@return {projects: Project[], selected_index: number|nil, active_window: ProjectWindowType, detail_index: number|nil}
function ProjectController:get_view_data()
    return {
        projects = project_store:get_projects(),
        selected_index = project_ui_state:get_selected_index(),
        active_window = project_ui_state:get_active_window(),
        detail_index = project_ui_state:get_detail_index()
    }
end

function ProjectController:create_project(name)
    local project = Project.create(name)
    project_service:save_project(project)
    project_store:add_project(project)

    -- Select the newly created project
    local index = project_store:get_project_index(project.id)
    if index ~= nil then
        project_ui_state:set_selected_index(index)
    end

    render_controller:render()
end

function ProjectController:move_up()
    local selected = project_ui_state:get_selected_index()
    if selected == nil then
        return
    end

    if project_ui_state:get_active_window() == "list" then
        if selected > 0 then
            project_ui_state:set_selected_index(selected - 1)
        end
    elseif project_ui_state:get_active_window() == "detail" then
        self:detail_move_up()
        return
    end
    render_controller:render()
end

function ProjectController:move_down()
    local selected = project_ui_state:get_selected_index()
    if selected == nil then
        return
    end

    if project_ui_state:get_active_window() == "list" then
        local project_count = project_store:get_project_count()
        if selected < project_count - 1 then
            project_ui_state:set_selected_index(selected + 1)
        end
    elseif project_ui_state:get_active_window() == "detail" then
        self:detail_move_down()
        return
    end
    render_controller:render()
end

function ProjectController:detail_move_up()
    local detail_index = project_ui_state:get_detail_index()
    if detail_index == nil then
        return
    end

    if detail_index > constants.PROJECT_NAME_LINE_INDEX then
        project_ui_state:set_detail_index(detail_index - 1)
    end
    render_controller:render()
end

function ProjectController:detail_move_down()
    local detail_index = project_ui_state:get_detail_index()
    if detail_index == nil then
        return
    end

    -- Only one editable field (name), so no movement needed
    if detail_index < constants.PROJECT_NAME_LINE_INDEX then
        project_ui_state:set_detail_index(detail_index + 1)
    end
    render_controller:render()
end

function ProjectController:remove_project()
    if project_ui_state:get_active_window() ~= "list" or project_ui_state:get_selected_index() == nil then
        return
    end

    local project = self:get_selected_project()
    if project == nil then
        return
    end

    project_service:delete_project(project)
    project_store:remove_project(project.id)

    -- Adjust selected index if needed
    local project_count = project_store:get_project_count()
    local selected = project_ui_state:get_selected_index()
    if project_count == 0 then
        project_ui_state:set_selected_index(nil)
    elseif selected ~= nil and selected >= project_count then
        project_ui_state:set_selected_index(project_count - 1)
    end

    render_controller:render()
end

function ProjectController:show_edit()
    local project = self:get_selected_project()

    if project == nil then
        return
    end

    local detail_index = project_ui_state:get_detail_index()

    if detail_index == constants.PROJECT_NAME_LINE_INDEX then
        local callback = function(new_value)
            if new_value == nil then
                return
            end

            local current_project = self:get_selected_project()
            if current_project then
                local updated_project = Project.with_name(current_project, new_value)
                project_service:save_project(updated_project)
                project_store:update_project(updated_project)
            end
            render_controller:render()
        end

        render_controller:add_view("input", { callback = callback, data = project.name })
    end
end

function ProjectController:close()
    if project_ui_state:get_active_window() == "detail" then
        project_ui_state:set_active_window("list")
        render_controller:render()
        return
    end
    render_controller:remove_view("status_bar", false)
    render_controller:remove_view("project")
end

function ProjectController:do_action()
    if project_ui_state:get_selected_index() == nil then
        return
    end

    if project_ui_state:get_active_window() == "list" then
        self:edit_project()
        render_controller:render()
    elseif project_ui_state:get_active_window() == "detail" then
        self:show_edit()
    end
end

function ProjectController:edit_project()
    if project_store:get_project_count() == 0 then
        return
    end

    project_ui_state:set_active_window("detail")
    project_ui_state:set_detail_index(constants.PROJECT_NAME_LINE_INDEX)
end

return ProjectController
