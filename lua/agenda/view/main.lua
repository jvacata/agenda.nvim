local MainView = {}

function MainView:init()
end

function MainView:render()
end

function MainView:destroy(winnr)
    vim.api.nvim_win_close(winnr, true)
end

return MainView
