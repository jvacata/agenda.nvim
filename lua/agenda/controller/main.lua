local MainController = {}

local render_controller = require('agenda.controller.render')

function MainController:init()
end

function MainController:init_view()
end

function MainController:route(args)
    if args == "tasks" then
        render_controller:set_view("task")
    else
        render_controller:set_view("main")
    end
end

return MainController
