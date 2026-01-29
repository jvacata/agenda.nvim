local InputView = {}

local window_config = require("agenda.config.window")
local window_util = require("agenda.util.window")

InputView.bufnr = nil
InputView.winnr = nil
InputView.data = ""

function InputView:init()
    self.edit_bufnr, self.edit_winnr = window_util:get_win("agenda_task_edit", window_config:task_edit_window())
end

function InputView:render()
    window_util.clean_buffer(self.bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })
    vim.api.nvim_buf_set_lines(self.bufnr, 0, 1, false, { self.data })
    vim.api.nvim_set_option_value('guicursor',
        'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor', {})
end

function InputView:destroy()
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})
    vim.api.nvim_win_close(self.winnr, true)
end

return InputView
