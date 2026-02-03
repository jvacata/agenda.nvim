local StatusBarView = {}

local window_util = require('agenda.util.window')
local window_config = require('agenda.config.window')

---@type number|nil
StatusBarView.bufnr = nil
---@type number|nil
StatusBarView.winnr = nil

function StatusBarView:init()
    local current_win = vim.api.nvim_get_current_win()
    self.bufnr, self.winnr = window_util:get_win("agenda_status_bar", window_config:status_bar_window())
    vim.api.nvim_set_current_win(current_win)
end

---Render the status bar with provided data
---@param view_data {content: string}|nil
function StatusBarView:render(view_data)
    window_util:clean_buffer(self.bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })

    local content = view_data and view_data.content or ""
    vim.api.nvim_buf_set_lines(self.bufnr, 0, 1, false, { content })

    vim.api.nvim_set_option_value('modifiable', false, { buf = self.bufnr })
end

function StatusBarView:destroy()
    if self.winnr and vim.api.nvim_win_is_valid(self.winnr) then
        vim.api.nvim_win_close(self.winnr, true)
    end
end

return StatusBarView
