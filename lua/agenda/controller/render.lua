local RenderController = {}

local table_utils = require("agenda.util.table")

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

function RenderController:remove_view(view_name, render)
    if render == nil then
        render = true
    end

    for i, v in ipairs(self.active_views) do
        if v == view_name then
            table.remove(self.active_views, i)
            local view_instance = self.view_config[view_name].view
            view_instance:destroy()
            break
        end
    end

    if render == false then
        return
    end

    self:render()
end

function RenderController:init_view(view_name, params)
    self.view_config[view_name].controller:init_view(params)
end

---Render all active views
---Gets view data from each controller and passes it to the corresponding view
function RenderController:render()
    for _, view_name in ipairs(self.active_views) do
        local config = self.view_config[view_name]
        local view_instance = config.view
        local controller = config.controller

        -- Get view data from controller if it has get_view_data method
        local view_data = nil
        if controller.get_view_data then
            view_data = controller:get_view_data()
        end

        -- Pass view data to view's render method
        view_instance:render(view_data)
    end
end

function RenderController:destroy()
    local active_views_copy = table_utils:deep_copy_array(self.active_views)

    for _, view_name in ipairs(active_views_copy) do
        self:remove_view(view_name, false)
    end
end

return RenderController
