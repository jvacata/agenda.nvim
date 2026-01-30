local InputView = {}

local input_model = require("agenda.model.input")
local window_config = require("agenda.config.window")
local window_util = require("agenda.util.window")

InputView.bufnr = nil
InputView.winnr = nil

function InputView:init()
    InputView.bufnr, InputView.winnr = window_util:get_win("agenda_task_edit", window_config:task_edit_window())
    window_util:clean_buffer(self.bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })
    vim.api.nvim_buf_set_lines(self.bufnr, 0, 1, false, { input_model.input })
end

function InputView:render()
    window_util:show_cursor()
end

function InputView:destroy()
    vim.api.nvim_win_close(self.winnr, true)
end

return InputView
