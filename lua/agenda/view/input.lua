local InputView = {}

local window_config = require("agenda.config.window")
local window_util = require("agenda.util.window")

InputView.bufnr = nil
InputView.winnr = nil

---Initialize the input view with a value
---@param value string
function InputView:init(value)
    InputView.bufnr, InputView.winnr = window_util:get_win("agenda_task_edit", window_config:task_edit_window())
    window_util:clean_buffer(self.bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })
    vim.api.nvim_buf_set_lines(self.bufnr, 0, 1, false, { value or "" })
end

---Render the input view (show cursor)
---@param view_data {value: string}|nil
function InputView:render(view_data)
    window_util:show_cursor()
end

---Get the current value from the buffer
---@return string
function InputView:get_buffer_value()
    return vim.api.nvim_buf_get_lines(self.bufnr, 0, 1, false)[1] or ""
end

function InputView:destroy()
    vim.api.nvim_win_close(self.winnr, true)
end

return InputView
