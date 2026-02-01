local MainController = {}

local render_controller = require('agenda.controller.render')

function MainController:init()
end

function MainController:init_view()
end

function MainController:route(args)
    if args == "tasks" then
        render_controller:set_view("task")
    elseif args == "kanban" then
        render_controller:set_view("kanban")
    else
        -- TODO fallback to task view, because main view is not implemented yet
        render_controller:set_view("task")
    end
end

return MainController
