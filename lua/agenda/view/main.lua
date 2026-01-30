local MainView = {}

function MainView:init()
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
