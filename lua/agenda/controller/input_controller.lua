local M = {}

local input_view = require("agenda.view.input")
local window_util = require("agenda.util.window")

M.callback = nil

M.initialize = function(callback)
    M.callback = callback

    M.set_edit_window_mapping(edit_bufnr, edit_winnr, list_bufnr, detail_bufnr)
end

M.set_edit_window_mapping = function(bufnr, winnr, list_bufnr, detail_bufnr)
    vim.keymap.set('n', 'q', function() M.cancel_edit(winnr) end,
        { buffer = true, silent = true })
    vim.keymap.set('n', '<CR>', function() M.close_edit(winnr, bufnr, list_bufnr, detail_bufnr) end,
        { buffer = true, silent = true })
end

M.cancel_edit = function(winnr)
    input_view.destroy()
    M.callback()
end

M.close_edit = function(winnr, bufnr, list_bufnr, detail_bufnr)
    local value = M.get_value()
    input_view.destroy()
    M.callback(value)

end

M.get_value = function()
    return vim.api.nvim_buf_get_lines(input_view.bufnr, 0, 1, false)[1]
end


return M
