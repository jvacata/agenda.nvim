---@class Epic
---@field id string -- id in uuid format
---@field name string
---@field description string|nil

local Epic = {}

local common_util = require('agenda.util.common')

---Create a new epic with generated UUID
---@param name string
---@return Epic
function Epic.create(name)
    return {
        id = common_util:generate_uuid_v4(),
        name = name or "",
        description = nil
    }
end

---Create a copy of epic with updated name
---@param epic Epic
---@param new_name string
---@return Epic
function Epic.with_name(epic, new_name)
    return {
        id = epic.id,
        name = new_name,
        description = epic.description
    }
end

---Create a copy of epic with updated description
---@param epic Epic
---@param new_description string|nil
---@return Epic
function Epic.with_description(epic, new_description)
    return {
        id = epic.id,
        name = epic.name,
        description = new_description
    }
end

return Epic
