local RenderController = {}

RenderController.active_views = {}
RenderController.views = {}

function RenderController:init(view_config)
    RenderController.views = view_config
end

function RenderController:add_view(view_name)
    table.insert(RenderController.active_views, view_name)
    RenderController.views[view_name].view:init()
    RenderController.views[view_name].controller:bind_mapping()
end

function RenderController:set_view(view_name)
    RenderController.active_views = {}
    table.insert(RenderController.active_views, view_name)
    RenderController.views[view_name].view:init()
    RenderController.views[view_name].controller:bind_mapping()
end

function RenderController:render()
    for _, view_name in pairs(RenderController.active_views) do
        local view_instance = RenderController.views[view_name].view
        view_instance:render()
    end
end

function RenderController:close()
    for _, view_name in pairs(RenderController.active_views) do
        local view_instance = RenderController.views[view_name].view
        view_instance:close()
    end
end

return RenderController
