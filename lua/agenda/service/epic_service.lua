local EpicService = {}

local epic_store = require('agenda.model.entity.epic_store')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local string_utils = require('agenda.util.string')

local autosave_service = require('agenda.service.autosave_service')

---Save an epic to disk
---@param epic Epic
function EpicService:save_epic(epic)
    if not string_utils:is_valid_id(epic.id) then
        error("Epic must have a valid id to be saved")
    end

    file_utils:save_file(global_config.workspace_epic_path, epic.id, vim.json.encode(epic))
    autosave_service:autosave()
end

---Delete an epic from disk
---@param epic Epic
function EpicService:delete_epic(epic)
    file_utils:remove_file(global_config.workspace_epic_path, epic.id)
end

---Load all epics from disk into EpicStore
function EpicService:init_load_epics()
    local epics = {}
    local epic_files = file_utils:get_dir_files(global_config.workspace_epic_path)
    for _, epic_file in ipairs(epic_files) do
        local data = file_utils:load_file(epic_file)
        if type(data) == "table" and data.id ~= nil and string_utils:is_valid_id(data.id) then
            table.insert(epics, data)
        end
    end
    epic_store:init_with_epics(epics)
end

return EpicService
