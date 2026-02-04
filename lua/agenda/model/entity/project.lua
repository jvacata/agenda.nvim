---@class Project
---@field id string -- id in uuid format
---@field name string

local Project = {}

local common_util = require('agenda.util.common')

---Create a new project with generated UUID
---@param name string
---@return Project
function Project.create(name)
    return {
        id = common_util:generate_uuid_v4(),
        name = name or ""
    }
end

---Create a copy of project with updated name
---@param project Project
---@param new_name string
---@return Project
function Project.with_name(project, new_name)
    return {
        id = project.id,
        name = new_name
    }
end

return Project
