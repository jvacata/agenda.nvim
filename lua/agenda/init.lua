local M = {}

local global_config = require('agenda.config.global')
local main_controller = require('agenda.controller.main')
local render_controller = require('agenda.controller.render')
local input_controller = require('agenda.controller.input')
local task_controller = require('agenda.controller.task')
local kanban_controller = require('agenda.controller.kanban')
local task_store = require('agenda.model.task_store')
local task_ui_state = require('agenda.model.task_ui_state')
local kanban_store = require('agenda.model.kanban_store')
local kanban_ui_state = require('agenda.model.kanban_ui_state')

local main_view = require('agenda.view.main')
local task_view = require('agenda.view.task')
local input_view = require('agenda.view.input')
local kanban_view = require('agenda.view.kanban')

local is_loaded = false

M.setup = function(user_config)
    global_config:init(user_config)
    M.create_commands()
end

M.init_instances = function()
    vim.api.nvim_set_hl(0, "NoCursor", { fg = "#000000", bg = "#000000", blend = 100 })

    -- Reset stores on initialization
    task_store:reset()
    task_ui_state:reset()
    kanban_store:reset()
    kanban_ui_state:reset()

    main_controller:init()
    task_controller:init()
    input_controller:init()
    kanban_controller:init()

    render_controller:init(
        {
            main = { view = main_view, controller = main_controller },
            task = { view = task_view, controller = task_controller },
            input = { view = input_view, controller = input_controller },
            kanban = { view = kanban_view, controller = kanban_controller }
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
