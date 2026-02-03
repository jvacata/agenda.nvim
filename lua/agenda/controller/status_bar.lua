local StatusBarController = {}

local status_bar_view = require('agenda.view.status_bar')

function StatusBarController:init()
end

function StatusBarController:init_view()
    status_bar_view:init()
end

---Get view data for rendering
---@return {content: string}
function StatusBarController:get_view_data()
    return {
        content = ""
    }
end

return StatusBarController
