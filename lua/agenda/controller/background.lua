local BackgroundController = {}

local background_view = require('agenda.view.background')

function BackgroundController:init()
end

function BackgroundController:init_view()
    background_view:init()
end

return BackgroundController
