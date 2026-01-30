local TableUtils = {}

function TableUtils:deepCopy(original)
    local copy = {}
    for k, v in ipairs(original) do
        if type(v) == "table" then
            copy[k] = self:deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

return TableUtils
