---@class EpicStore
---@field private _epics Epic[]
local EpicStore = {}

EpicStore._epics = {}

---Get all epics (returns a copy to prevent external mutation)
---@return Epic[]
function EpicStore:get_epics()
    local copy = {}
    for i, epic in ipairs(self._epics) do
        copy[i] = epic
    end
    return copy
end

---Get epic count
---@return number
function EpicStore:get_epic_count()
    return #self._epics
end

---Get epic by index (1-based)
---@param index number
---@return Epic|nil
function EpicStore:get_epic(index)
    return self._epics[index]
end

---Get epic by id
---@param id string
---@return Epic|nil
function EpicStore:get_epic_by_id(id)
    for _, epic in ipairs(self._epics) do
        if epic.id == id then
            return epic
        end
    end
    return nil
end

---Add a new epic
---@param epic Epic
function EpicStore:add_epic(epic)
    table.insert(self._epics, epic)
end

---Update an existing epic
---@param epic Epic
---@return boolean success
function EpicStore:update_epic(epic)
    for i, existing in ipairs(self._epics) do
        if existing.id == epic.id then
            self._epics[i] = epic
            return true
        end
    end
    return false
end

---Remove an epic by id
---@param epic_id string
---@return boolean success
function EpicStore:remove_epic(epic_id)
    for i, epic in ipairs(self._epics) do
        if epic.id == epic_id then
            table.remove(self._epics, i)
            return true
        end
    end
    return false
end

---Get index of an epic (0-based for UI compatibility)
---@param epic_id string
---@return number|nil
function EpicStore:get_epic_index(epic_id)
    for i, epic in ipairs(self._epics) do
        if epic.id == epic_id then
            return i - 1
        end
    end
    return nil
end

---Initialize state with epics (used during load)
---@param epics Epic[]
function EpicStore:init_with_epics(epics)
    self._epics = epics or {}
end

---Reset all state to initial values
function EpicStore:reset()
    self._epics = {}
end

return EpicStore
