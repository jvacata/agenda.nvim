local ValueList = {}

ValueList.__index = ValueList

function ValueList:new()
    local instance = { items = {} }
    setmetatable(instance, self)
    return instance
end

function ValueList:add(item)
    table.insert(self.items, item)
end

function ValueList:remove(item)
    for i, v in pairs(self.items) do
        if v == item then
            table.remove(self.items, i)
            return true
        end
    end
    return false
end

function ValueList:get_all()
    return self.items
end

return ValueList
