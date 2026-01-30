local MainView = {}

local window_util = require('agenda.util.window')
local task_view = require('agenda.view.task')
local window_config = require('agenda.config.window')

function MainView:init()
end

function MainView:open(args)
    if args == "tasks" then
        task_view.open()
        return
    else
        local _, winnr = window_util:get_win("agenda_main", window_config:task_list_window())
        MainView:set_global_mapping(winnr)
    end
end

function MainView:set_global_mapping(winnr)
    vim.keymap.set('n', 'q', function() MainView:destroy(winnr) end, { buffer = true, silent = true })
end

function MainView:render()
end

function MainView:destroy(winnr)
    vim.api.nvim_win_close(winnr, true)
end

return MainView
