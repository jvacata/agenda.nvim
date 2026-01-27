local M = {}

local window_common = require('agenda.window.common')
local task_window = require('agenda.window.tasks')

M.open = function(args)
    vim.api.nvim_set_hl(0, "NoCursor", { fg = "#000000", bg = "#000000", blend = 100 })
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})

    local _, winnr = window_common.get_win()
    M.set_global_mapping(winnr)

    if args == "tasks" then
        task_window.open()
        return
    end
end

M.set_global_mapping = function(winnr)
    vim.keymap.set('n', 'q', function() M.close(winnr) end, { buffer = true, silent = true })
end

M.close = function(winnr)
    vim.api.nvim_win_close(winnr, true)
end

return M
