local StatusBarController = {}

local status_bar_view = require('agenda.view.status_bar')
local autosave_state = require('agenda.model.ui.autosave_state')

local status_display = {
    saved = "Saved",
    saving = "Saving",
    not_saved = "Not saved",
}

function StatusBarController:init()
end

function StatusBarController:init_view()
    status_bar_view:init()
end

---Get view data for rendering
---@return {content: string}
function StatusBarController:get_view_data()
    local status = autosave_state:get_status()
    local display = status_display[status] or "Unknown"
    return {
        content = "Autosave status: " .. display
    }
end

return StatusBarController
