local RenderController = {}

RenderController.active_views = {}
RenderController.view_config = {}

function RenderController:init(view_config)
    self.view_config = view_config
end

function RenderController:add_view(view_name, params)
    if self:is_view_active(view_name) then
        return
    end

    table.insert(self.active_views, view_name)
    self:init_view(view_name, params)
    self:render()
end

function RenderController:is_view_active(view_name)
    for _, v in ipairs(self.active_views) do
        if v == view_name then
            return true
        end
    end
    return false
end

function RenderController:set_view(view_name, params)
    self:destroy()
    self.active_views = {}
    table.insert(self.active_views, view_name)
    self:init_view(view_name, params)
    self:render()
end

function RenderController:remove_view(view_name)
    for i, v in ipairs(self.active_views) do
        if v == view_name then
            table.remove(self.active_views, i)
            local view_instance = self.view_config[view_name].view
            view_instance:destroy()
            break
        end
    end
    self:render()
end

function RenderController:init_view(view_name, params)
    self.view_config[view_name].controller:init_view(params)
end

function RenderController:render()
    for _, view_name in ipairs(self.active_views) do
        local view_instance = self.view_config[view_name].view
        view_instance:render()
    end
end

function RenderController:destroy()
    for _, view_name in ipairs(self.active_views) do
        self:remove_view(view_name)
    end
end

return RenderController
