local EpicView = {}

local constants = require('agenda.constants')
local window_util = require('agenda.util.window')
local global_config = require('agenda.config.global')
local window_config = require('agenda.config.window')

---@type number
EpicView.list_bufnr = nil
---@type number
EpicView.list_winnr = nil
---@type number
EpicView.detail_bufnr = nil
---@type number
EpicView.detail_winnr = nil
---@type number
EpicView.task_list_bufnr = nil
---@type number
EpicView.task_list_winnr = nil

function EpicView:init()
    self.list_bufnr, self.list_winnr = window_util:get_win("agenda_epic_list", window_config:epic_list_window())
    self.detail_bufnr, self.detail_winnr = window_util:get_win("agenda_epic_detail", window_config:epic_detail_window())
    self.task_list_bufnr, self.task_list_winnr = window_util:get_win("agenda_epic_task_list",
        window_config:epic_task_list_window())
    vim.api.nvim_set_current_win(self.list_winnr)
end

---Render the epic view with provided data
---@param view_data {epics: Epic[], selected_index: number|nil, active_window: EpicWindowType, detail_index: number|nil, linked_tasks: Task[]}
function EpicView:render(view_data)
    window_util:hide_cursor()
    self:render_epic_list(view_data)
    self:render_epic_detail(view_data)
    self:render_task_list(view_data)
end

---Render the epic list
---@param view_data {epics: Epic[], selected_index: number|nil, active_window: EpicWindowType, detail_index: number|nil}
function EpicView:render_epic_list(view_data)
    window_util:clean_buffer(self.list_bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.list_bufnr })
    for i, epic in ipairs(view_data.epics) do
        vim.api.nvim_buf_set_lines(self.list_bufnr, i - 1, i, false, { epic.name })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.list_bufnr })

    self:highlight_list_line(view_data)
end

---Render the epic detail panel
---@param view_data {epics: Epic[], selected_index: number|nil, active_window: EpicWindowType, detail_index: number|nil}
function EpicView:render_epic_detail(view_data)
    window_util:clean_buffer(self.detail_bufnr)
    if #view_data.epics == 0 or view_data.selected_index == nil then
        return
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.detail_bufnr })
    local epic = view_data.epics[view_data.selected_index + 1]
    if epic then
        vim.api.nvim_buf_set_lines(self.detail_bufnr, constants.EPIC_ID_LINE_INDEX,
            constants.EPIC_ID_LINE_INDEX + 1, false,
            { "Id: " .. epic.id })
        vim.api.nvim_buf_set_lines(self.detail_bufnr, constants.EPIC_NAME_LINE_INDEX,
            constants.EPIC_NAME_LINE_INDEX + 1, false,
            { "Name: " .. epic.name })
        vim.api.nvim_buf_set_lines(self.detail_bufnr, constants.EPIC_DESCRIPTION_LINE_INDEX,
            constants.EPIC_DESCRIPTION_LINE_INDEX + 1, false,
            { "Description: " .. self:get_description_preview(epic.description) })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.detail_bufnr })

    self:highlight_detail_line(view_data)
end

---Render the linked task list panel
---@param view_data {epics: Epic[], selected_index: number|nil, linked_tasks: Task[]}
function EpicView:render_task_list(view_data)
    window_util:clean_buffer(self.task_list_bufnr)
    if #view_data.epics == 0 or view_data.selected_index == nil then
        return
    end

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.task_list_bufnr })
    for i, task in ipairs(view_data.linked_tasks) do
        vim.api.nvim_buf_set_lines(self.task_list_bufnr, i - 1, i, false, { task.title })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.task_list_bufnr })
end

---Get preview of description (first line, truncated)
---@param description string|nil
---@return string
function EpicView:get_description_preview(description)
    if description == nil then
        return "(empty)"
    end
    local first_line = vim.split(description, "\n", { plain = true })[1] or ""
    local max_len = 80
    if #first_line > max_len then
        return first_line:sub(1, max_len) .. "..."
    end
    return first_line
end

---Highlight the selected line in the list
---@param view_data {epics: Epic[], selected_index: number|nil, active_window: EpicWindowType}
function EpicView:highlight_list_line(view_data)
    self:clear_marks(self.list_bufnr)

    if view_data.selected_index == nil then
        return
    end

    local epic_count = #view_data.epics
    if epic_count > 0 then
        local epic = view_data.epics[view_data.selected_index + 1]
        if epic then
            local len = #epic.name
            self:highlight_line(self.list_bufnr, view_data.selected_index, len)
        end
    end
end

---Highlight the selected line in the detail panel
---@param view_data {detail_index: number|nil, active_window: EpicWindowType}
function EpicView:highlight_detail_line(view_data)
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
function EpicView:highlight_line(bufnr, line_index, len)
    vim.api.nvim_buf_set_extmark(bufnr, global_config.ns, line_index, 0, { end_col = len, hl_group = "Search" })
end

---Clear all extmarks from buffer
---@param bufnr number
function EpicView:clear_marks(bufnr)
    local all = vim.api.nvim_buf_get_extmarks(bufnr, global_config.ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bufnr, global_config.ns, mark[1])
    end
end

function EpicView:destroy()
    vim.api.nvim_win_close(self.list_winnr, true)
    vim.api.nvim_win_close(self.detail_winnr, true)
    vim.api.nvim_win_close(self.task_list_winnr, true)
end

return EpicView
