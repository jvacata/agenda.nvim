local InputView = {}

local window_config = require("agenda.config.window")
local window_util = require("agenda.util.window")

InputView.bufnr = nil
InputView.winnr = nil
InputView.mode = "edit"
InputView.ns_id = vim.api.nvim_create_namespace("agenda_input_select")

---Initialize the input view with a value or options
---@param value string|string[] For edit mode: initial string. For select mode: list of options. For multiline: string with newlines.
---@param mode? "edit"|"select"|"multiline" Defaults to "edit"
function InputView:init(value, mode)
    self.mode = mode or "edit"
    local win_config
    if self.mode == "select" then
        win_config = window_config:task_edit_window(5)
    elseif self.mode == "multiline" then
        win_config = window_config:task_edit_window(20, 80)
    else
        win_config = window_config:task_edit_window(1)
    end
    InputView.bufnr, InputView.winnr = window_util:get_win("agenda_task_edit", win_config)
    window_util:clean_buffer(self.bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })

    if self.mode == "select" then
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, value or {})
        vim.api.nvim_set_option_value('modifiable', false, { buf = self.bufnr })
    elseif self.mode == "multiline" then
        local lines = vim.split(value or "", "\n", { plain = true })
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
    else
        vim.api.nvim_buf_set_lines(self.bufnr, 0, 1, false, { value or "" })
    end
end

---Render the input view
---@param view_data {value: string, selected_index: number}|nil
function InputView:render(view_data)
    if self.mode == "select" and view_data then
        self:highlight_selection(view_data.selected_index)
    else
        window_util:show_cursor()
    end
end

---Highlight the selected line in select mode
---@param index number
function InputView:highlight_selection(index)
    vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
    if index and index > 0 then
        vim.api.nvim_buf_add_highlight(self.bufnr, self.ns_id, "Visual", index - 1, 0, -1)
        vim.api.nvim_win_set_cursor(self.winnr, { index, 0 })
    end
end

---Get the current value from the buffer
---@return string|nil
function InputView:get_buffer_value()
    if self.mode == "multiline" then
        local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
        local value = table.concat(lines, "\n")
        if value == "" then
            return nil
        end
        return value
    end
    return vim.api.nvim_buf_get_lines(self.bufnr, 0, 1, false)[1] or ""
end

function InputView:destroy()
    vim.api.nvim_win_close(self.winnr, true)
end

return InputView
