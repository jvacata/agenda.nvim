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

function ValueList:clear()
    self.items = {}
end

return ValueList
