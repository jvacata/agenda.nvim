local M = {}

local main_window = require('agenda.window.main')

M.setup = function(opts)
    M.create_commands()
end

M.create_commands = function()
    vim.api.nvim_create_user_command("Agenda", function(opts)
        main_window.open(opts.args)
    end, {
        nargs = '*',
        desc = 'Open agenda buffer',
        complete = 'command',
    })
end

return M
