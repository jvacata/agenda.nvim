local M = {}

local global_config = require('agenda.config.global')
local main_controller = require('agenda.controller.main')
local render_controller = require('agenda.controller.render')
local input_controller = require('agenda.controller.input')
local task_controller = require('agenda.controller.task')

local main_view = require('agenda.view.main')
local task_view = require('agenda.view.task')
local input_view = require('agenda.view.input')

local is_loaded = false

M.setup = function(user_config)
    global_config:init(user_config)
    M.create_commands()
end

M.init_instances = function()
    vim.api.nvim_set_hl(0, "NoCursor", { fg = "#000000", bg = "#000000", blend = 100 })

    main_controller:init()
    task_controller:init()
    input_controller:init()

    render_controller:init(
        {
            main = { view = main_view, controller = main_controller },
            task = { view = task_view, controller = task_controller },
            input = { view = input_view, controller = input_controller }
        }
    )
end

M.create_commands = function()
    vim.api.nvim_create_user_command("Agenda", function(opts)
        if not is_loaded then
            M.init_instances()
            is_loaded = true
        end

        main_controller:route(opts.args)
    end, {
        nargs = '*',
        desc = 'Open agenda buffer',
        complete = 'command',
    })
end

return M
