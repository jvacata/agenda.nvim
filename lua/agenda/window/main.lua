local M = {}

local window_common = require('agenda.window.common')

M.open = function()
    window_common.create_or_find_main_window()
end

return M
