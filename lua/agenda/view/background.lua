local BackgroundView = {}

local window_util = require('agenda.util.window')
local window_config = require('agenda.config.window')

---@type number|nil
BackgroundView.bufnr = nil
---@type number|nil
BackgroundView.winnr = nil

function BackgroundView:init()
    local current_win = vim.api.nvim_get_current_win()
    self.bufnr, self.winnr = window_util:get_win("agenda_background", window_config:background_window())
    vim.api.nvim_set_option_value('winhighlight', 'Normal:AgendaBackground', { win = self.winnr })
    vim.api.nvim_set_current_win(current_win)
end

function BackgroundView:render()
end

function BackgroundView:destroy()
    if self.winnr and vim.api.nvim_win_is_valid(self.winnr) then
        vim.api.nvim_win_close(self.winnr, true)
    end
end

return BackgroundView
