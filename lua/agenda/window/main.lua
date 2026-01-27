local M = {}

local window_common = require('agenda.window.common')
local task_window = require('agenda.window.tasks')

M.open = function()
    task_window.open()
end

return M
