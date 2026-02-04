local KanbanView = {}

local window_util = require('agenda.util.window')
local global_config = require('agenda.config.global')
local window_config = require('agenda.config.window')

-- Buffer and window references for board
---@type number
KanbanView.bufnr = nil
---@type number
KanbanView.winnr = nil

-- Buffer and window references for project panel
---@type number
KanbanView.project_bufnr = nil
---@type number
KanbanView.project_winnr = nil

-- Column configuration
local COLUMN_WIDTH = 30
local COLUMN_PADDING = 2

function KanbanView:init()
    self.project_bufnr, self.project_winnr = window_util:get_win("agenda_kanban_projects", window_config:kanban_project_panel_window())
    self.bufnr, self.winnr = window_util:get_win("agenda_kanban", window_config:kanban_window())
    vim.api.nvim_set_current_win(self.project_winnr)
end

---Render the kanban view with provided data
---@param view_data {columns: table<string, Task[]>, column_names: string[], column_titles: table<string, string>, selected_column: string, selected_row: number|nil, project_list: string[], project_list_index: number, focus: string}
function KanbanView:render(view_data)
    window_util:hide_cursor()

    -- Render project panel
    self:render_project_panel(view_data)

    -- Render board
    window_util:clean_buffer(self.bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })

    local lines = self:build_board_lines(view_data)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)

    vim.api.nvim_set_option_value('modifiable', false, { buf = self.bufnr })

    self:highlight_selected(view_data)
    self:highlight_project_selection(view_data)
end

---Render the project panel
---@param view_data {project_list: string[], project_list_index: number, focus: string}
function KanbanView:render_project_panel(view_data)
    window_util:clean_buffer(self.project_bufnr)

    vim.api.nvim_set_option_value('modifiable', true, { buf = self.project_bufnr })
    for i, project_name in ipairs(view_data.project_list) do
        vim.api.nvim_buf_set_lines(self.project_bufnr, i - 1, i, false, { project_name })
    end
    vim.api.nvim_set_option_value('modifiable', false, { buf = self.project_bufnr })
end

---Highlight the selected project in the panel
---@param view_data {project_list: string[], project_list_index: number, focus: string}
function KanbanView:highlight_project_selection(view_data)
    self:clear_project_marks()

    if view_data.focus ~= "project_list" then
        return
    end

    local project_name = view_data.project_list[view_data.project_list_index + 1]
    if project_name then
        local len = #project_name
        vim.api.nvim_buf_set_extmark(self.project_bufnr, global_config.ns, view_data.project_list_index, 0,
            { end_col = len, hl_group = "Search" })
    end
end

---Clear all extmarks from project buffer
function KanbanView:clear_project_marks()
    local all = vim.api.nvim_buf_get_extmarks(self.project_bufnr, global_config.ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(self.project_bufnr, global_config.ns, mark[1])
    end
end

---Build the lines for the kanban board
---@param view_data {columns: table<string, Task[]>, column_names: string[], column_titles: table<string, string>, selected_column: string, selected_row: number|nil}
---@return string[]
function KanbanView:build_board_lines(view_data)
    local lines = {}

    -- Build header line with column titles
    local header = ""
    for i, column_name in ipairs(view_data.column_names) do
        local title = view_data.column_titles[column_name]
        local padded_title = self:center_text(title, COLUMN_WIDTH)
        header = header .. padded_title
        if i < #view_data.column_names then
            header = header .. string.rep(" ", COLUMN_PADDING)
        end
    end
    table.insert(lines, header)

    -- Build separator line
    local separator = ""
    for i, _ in ipairs(view_data.column_names) do
        separator = separator .. string.rep("-", COLUMN_WIDTH)
        if i < #view_data.column_names then
            separator = separator .. string.rep(" ", COLUMN_PADDING)
        end
    end
    table.insert(lines, separator)

    -- Find max tasks in any column
    local max_tasks = 0
    for _, column_name in ipairs(view_data.column_names) do
        local count = #(view_data.columns[column_name] or {})
        if count > max_tasks then
            max_tasks = count
        end
    end

    -- Build task rows
    for row = 1, max_tasks do
        local line = ""
        for i, column_name in ipairs(view_data.column_names) do
            local tasks = view_data.columns[column_name] or {}
            local task = tasks[row]
            local cell = ""
            if task then
                cell = self:truncate_text(task.title, COLUMN_WIDTH - 2)
                cell = " " .. cell .. string.rep(" ", COLUMN_WIDTH - #cell - 1)
            else
                cell = string.rep(" ", COLUMN_WIDTH)
            end
            line = line .. cell
            if i < #view_data.column_names then
                line = line .. string.rep(" ", COLUMN_PADDING)
            end
        end
        table.insert(lines, line)
    end

    -- Add empty line if no tasks
    if max_tasks == 0 then
        local empty_line = ""
        for i, _ in ipairs(view_data.column_names) do
            empty_line = empty_line .. string.rep(" ", COLUMN_WIDTH)
            if i < #view_data.column_names then
                empty_line = empty_line .. string.rep(" ", COLUMN_PADDING)
            end
        end
        table.insert(lines, empty_line)
    end

    return lines
end

---Center text within a given width
---@param text string
---@param width number
---@return string
function KanbanView:center_text(text, width)
    local padding = width - #text
    local left_pad = math.floor(padding / 2)
    local right_pad = padding - left_pad
    return string.rep(" ", left_pad) .. text .. string.rep(" ", right_pad)
end

---Truncate text to fit within width
---@param text string
---@param width number
---@return string
function KanbanView:truncate_text(text, width)
    if #text <= width then
        return text
    end
    return string.sub(text, 1, width - 3) .. "..."
end

---Highlight the selected column header and task
---@param view_data {columns: table<string, Task[]>, column_names: string[], column_titles: table<string, string>, selected_column: string, selected_row: number|nil}
function KanbanView:highlight_selected(view_data)
    self:clear_marks()

    -- Find column index
    local col_index = 0
    for i, name in ipairs(view_data.column_names) do
        if name == view_data.selected_column then
            col_index = i
            break
        end
    end

    if col_index == 0 then
        return
    end

    -- Calculate start column position
    local start_col = (col_index - 1) * (COLUMN_WIDTH + COLUMN_PADDING)

    -- Highlight column header
    local title = view_data.column_titles[view_data.selected_column]
    local title_padding = math.floor((COLUMN_WIDTH - #title) / 2)
    local title_start = start_col + title_padding
    vim.api.nvim_buf_set_extmark(self.bufnr, global_config.ns, 0, title_start,
        { end_col = title_start + #title, hl_group = "Search" })

    -- Highlight selected task if any
    if view_data.selected_row == nil then
        return
    end

    local line_index = view_data.selected_row + 2 -- +2 for header and separator

    -- Get the task to highlight
    local tasks = view_data.columns[view_data.selected_column] or {}
    local task = tasks[view_data.selected_row + 1]
    if task then
        local text_len = math.min(#task.title + 2, COLUMN_WIDTH)
        vim.api.nvim_buf_set_extmark(self.bufnr, global_config.ns, line_index, start_col,
            { end_col = start_col + text_len, hl_group = "Search" })
    end
end

---Clear all extmarks from buffer
function KanbanView:clear_marks()
    local all = vim.api.nvim_buf_get_extmarks(self.bufnr, global_config.ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(self.bufnr, global_config.ns, mark[1])
    end
end

function KanbanView:destroy()
    vim.api.nvim_win_close(self.winnr, true)
    vim.api.nvim_win_close(self.project_winnr, true)
end

return KanbanView
