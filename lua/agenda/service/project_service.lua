local ProjectService = {}

local project_store = require('agenda.model.entity.project_store')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local string_utils = require('agenda.util.string')

local autosave_service = require('agenda.service.autosave_service')

---Save a project to disk
---@param project Project
function ProjectService:save_project(project)
    if not string_utils:is_valid_id(project.id) then
        error("Project must have a valid id to be saved")
    end

    file_utils:save_file(global_config.workspace_project_path, project.id, vim.json.encode(project))
    autosave_service:autosave()
end

---Delete a project from disk
---@param project Project
function ProjectService:delete_project(project)
    file_utils:remove_file(global_config.workspace_project_path, project.id)
end

---Load all projects from disk into ProjectStore
function ProjectService:init_load_projects()
    local projects = {}
    local project_files = file_utils:get_dir_files(global_config.workspace_project_path)
    for _, project_file in ipairs(project_files) do
        local data = file_utils:load_file(project_file)
        if type(data) == "table" and data.id ~= nil and string_utils:is_valid_id(data.id) then
            table.insert(projects, data)
        end
    end
    project_store:init_with_projects(projects)
end

return ProjectService
