local M = {}

local window_util = require("agenda.util.window")

M.bufnr = nil
M.winnr = nil
M.data = ""

M.initialize = function()
    M.edit_bufnr, M.edit_winnr = window_util.get_win("agenda_task_edit", window_util.task_edit_window())
end

M.render = function()
    window_util.clean_buffer(M.bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = M.bufnr })
    vim.api.nvim_buf_set_lines(M.bufnr, 0, 1, false, { M.data })
    vim.api.nvim_set_option_value('guicursor',
        'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor', {})
end

M.destroy = function()
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})
    vim.api.nvim_win_close(winnr, true)
end

return M
