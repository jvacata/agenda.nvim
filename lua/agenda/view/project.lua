local ProjectView = {}

local constants = require('agenda.constants')
local window_util = require('agenda.util.window')
local global_config = require('agenda.config.global')
local window_config = require('agenda.config.window')

-- Buffer and window references (view infrastructure, not state)
-- @type number
ProjectView.list_bufnr = nil
-- @type number
ProjectView.list_winnr = nil
-- @type number
ProjectView.detail_bufnr = nil
-- @type number
ProjectView.detail_winnr = nil

function ProjectView:init()
    self.list_bufnr, self.list_winnr = window_util:get_win("agenda_project_list", window_config:project_list_window())
    self.detail_bufnr, self.detail_winnr = window_util:get_win("agenda_project_detail", window_config:project_detail_window())
    vim.api.nvim_set_current_win(self.list_winnr)
end

---Render the project view with provided data
---@param view_data {projects: Project[], selected_index: number|nil, active_window: ProjectWindowType, detail_index: number|nil}
function ProjectView:render(view_data)
    window_util:hide_cursor()
    self:render_project_list(view_data)
    self:render_project_detail(view_data)
end

---Render the project list
---@param view_data {projects: Project[], selected_index: number|nil, active_window: ProjectWindowType, detail_index: number|nil}
function ProjectView:render_project_list(view_data)
    window_util:clean_buffer(self.list_bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.list_bufnr })
    for i, project in ipairs(view_data.projects) do
        vim.api.nvim_buf_set_lines(self.list_bufnr, i - 1, i, false, { project.name })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.list_bufnr })

    self:highlight_list_line(view_data)
end

---Render the project detail panel
---@param view_data {projects: Project[], selected_index: number|nil, active_window: ProjectWindowType, detail_index: number|nil}
function ProjectView:render_project_detail(view_data)
    window_util:clean_buffer(self.detail_bufnr)
    if #view_data.projects == 0 or view_data.selected_index == nil then
        return
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.detail_bufnr })
    local project = view_data.projects[view_data.selected_index + 1]
    if project then
        vim.api.nvim_buf_set_lines(self.detail_bufnr, constants.PROJECT_ID_LINE_INDEX, constants.PROJECT_ID_LINE_INDEX + 1, false,
            { "Id: " .. project.id })
        vim.api.nvim_buf_set_lines(self.detail_bufnr, constants.PROJECT_NAME_LINE_INDEX, constants.PROJECT_NAME_LINE_INDEX + 1, false,
            { "Name: " .. project.name })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.detail_bufnr })

    self:highlight_detail_line(view_data)
end

---Highlight the selected line in the list
---@param view_data {projects: Project[], selected_index: number|nil, active_window: ProjectWindowType, detail_index: number|nil}
function ProjectView:highlight_list_line(view_data)
    self:clear_marks(self.list_bufnr)

    if view_data.selected_index == nil then
        return
    end

    local project_count = #view_data.projects
    if project_count > 0 then
        local project = view_data.projects[view_data.selected_index + 1]
        if project then
            local len = #project.name
            self:highlight_line(self.list_bufnr, view_data.selected_index, len)
        end
    end
end

---Highlight the selected line in the detail panel
---@param view_data {projects: Project[], selected_index: number|nil, active_window: ProjectWindowType, detail_index: number|nil}
function ProjectView:highlight_detail_line(view_data)
    self:clear_marks(self.detail_bufnr)

    if view_data.detail_index == nil or view_data.active_window ~= "detail" then
        return
    end

    local line = vim.api.nvim_buf_get_lines(self.detail_bufnr, view_data.detail_index, view_data.detail_index + 1, false)
        [1]
    if line then
        local len = #line
        self:highlight_line(self.detail_bufnr, view_data.detail_index, len)
    end
end

---Apply highlight to a line
---@param bufnr number
---@param line_index number
---@param len number
function ProjectView:highlight_line(bufnr, line_index, len)
    vim.api.nvim_buf_set_extmark(bufnr, global_config.ns, line_index, 0, { end_col = len, hl_group = "Search" })
end

---Clear all extmarks from buffer
---@param bufnr number
function ProjectView:clear_marks(bufnr)
    local all = vim.api.nvim_buf_get_extmarks(bufnr, global_config.ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bufnr, global_config.ns, mark[1])
    end
end

function ProjectView:destroy()
    vim.api.nvim_win_close(self.list_winnr, true)
    vim.api.nvim_win_close(self.detail_winnr, true)
end

return ProjectView
