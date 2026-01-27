local M = {}

local window_common = require('agenda.window.common')
local task_window = require('agenda.window.tasks')
local window_config = require('agenda.config.window')

M.open = function(args)
    vim.api.nvim_set_hl(0, "NoCursor", { fg = "#000000", bg = "#000000", blend = 100 })
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})

    if args == "tasks" then
        task_window.open()
        return
    else
        local _, winnr = window_common.get_win("agenda_main", window_config.task_list_window())
        M.set_global_mapping(winnr)
    end
end

M.set_global_mapping = function(winnr)
    vim.keymap.set('n', 'q', function() M.close(winnr) end, { buffer = true, silent = true })
end

M.close = function(winnr)
    vim.api.nvim_win_close(winnr, true)
end

return M
