local AutosaveState = {}

---@alias AutosaveStatus "saved" | "saving" | "not_saved"

---@type AutosaveStatus
AutosaveState.status = "saved"

---Set autosave status
---@param status AutosaveStatus
function AutosaveState:set_status(status)
    self.status = status
end

---Get autosave status
---@return AutosaveStatus
function AutosaveState:get_status()
    return self.status
end

function AutosaveState:reset()
    self.status = "saved"
end

return AutosaveState
