local ValueList = {}

ValueList.__index = ValueList

function ValueList:new()
    local instance = { items = {} }
    setmetatable(instance, self)
    return instance
end

function ValueList:add_or_update(item)
    local items = self:get_all()
    local updated = false
    for index, existing in ipairs(items) do
        if existing.id == item.id then
            items[index] = item
            updated = true
            break
        end
    end
    if not updated then
        table.insert(self.items, item)
    end
end

function ValueList:remove(item)
    if item == nil or type(item) ~= "table" or item.id == nil then
        return
    end

    for i, v in pairs(self.items) do
        if v.id == item.id then
            table.remove(self.items, i)
            return true
        end
    end
end

function ValueList:get_all()
    return self.items
end

function ValueList:get_index(item)
    local items = self:get_all()
    for index, existing in ipairs(items) do
        if existing.id == item.id then
            return index
        end
    end
    return nil
end

function ValueList:clear()
    self.items = {}
end

return ValueList
