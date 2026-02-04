---@class ProjectStore
---@field private _projects Project[]
local ProjectStore = {}

ProjectStore._projects = {}

---Get all projects (returns a copy to prevent external mutation)
---@return Project[]
function ProjectStore:get_projects()
    local copy = {}
    for i, project in ipairs(self._projects) do
        copy[i] = project
    end
    return copy
end

---Get project count
---@return number
function ProjectStore:get_project_count()
    return #self._projects
end

---Get project by index (1-based)
---@param index number
---@return Project|nil
function ProjectStore:get_project(index)
    return self._projects[index]
end

---Get project by id
---@param id string
---@return Project|nil
function ProjectStore:get_project_by_id(id)
    for _, project in ipairs(self._projects) do
        if project.id == id then
            return project
        end
    end
    return nil
end

---Add a new project
---@param project Project
function ProjectStore:add_project(project)
    table.insert(self._projects, project)
end

---Update an existing project
---@param project Project
---@return boolean success
function ProjectStore:update_project(project)
    for i, existing in ipairs(self._projects) do
        if existing.id == project.id then
            self._projects[i] = project
            return true
        end
    end
    return false
end

---Remove a project by id
---@param project_id string
---@return boolean success
function ProjectStore:remove_project(project_id)
    for i, project in ipairs(self._projects) do
        if project.id == project_id then
            table.remove(self._projects, i)
            return true
        end
    end
    return false
end

---Get index of a project (0-based for UI compatibility)
---@param project_id string
---@return number|nil
function ProjectStore:get_project_index(project_id)
    for i, project in ipairs(self._projects) do
        if project.id == project_id then
            return i - 1
        end
    end
    return nil
end

---Initialize state with projects (used during load)
---@param projects Project[]
function ProjectStore:init_with_projects(projects)
    self._projects = projects or {}
end

---Reset all state to initial values
function ProjectStore:reset()
    self._projects = {}
end

return ProjectStore
