local system = class()

function system:new(cell_size)
    self.engine = HC.new(cell_size)
    self.items = {}
end

function system:item(key, shape, ...)
    assert(self:get(key) == nil, 'item: ' .. tostring(key) .. ' is already exists!')
    local item = {}
    item.key = key
    item.collider = self.engine[shape](self.engine, ...)
    item.collider.item = item
    setmetatable(item, {__index = item.key})
    return item
end

function system:add(...)
    table.insert(self.items, self:item(...))
end

function system:get(key)
    for i, item in ipairs(self.items) do
        if (item.key == key) then
            return item, i
        end
    end
end

function system:hasItem(key)
    local item = self:get(key)
    return (item ~= nil and item.key == key)
end

function system:errget(key)
    local item, pos = self:get(key)
    assert(item ~= nil, "can't find item: " .. tostring(key))
    return item, pos
end

function system:remove(key)
    local item, pos = self:errget(key)
    self.engine:remove(item.collider)
    table.remove(self.items, pos)
end

function system:rotate(key, dr, cx, cy)
    local item, pos = self:errget(key)
    item.collider:rotate(dr, cx, cy)
end

function system:setRotation(key, r, cx, cy)
    local item, pos = self:errget(key)
    item.collider:setRotation(r, cx, cy)
end

function system:rotation(key)
    local item, pos = self:errget(key)
    return item.collider:rotation()
end

function system:center(key)
    local item, pos = self:errget(key)
    return item.collider:center()
end

function system:bbox(key)
    local item, pos = self:errget(key)
    return item.collider:bbox()
end

function system:scale(key, s)
    local item, pos = self:errget(key)
    item.collider:scale(s)
end

function system:draw(key, mode)
    local item, pos = self:errget(key)
    item.collider:draw(mode)
end

function system:collidesWith(key, collider)
    local item, pos = self:errget(key)
    return item.collider:collidesWith(collider)
end

function system:contains(key, x, y)
    local item, pos = self:errget(key)
    return item.collider:contains(x, y)
end

function system:collisions(key)
    local item, pos = self:errget(key)
    return self.engine:collisions(item.collider)
end

function system:intersectsRay(key, x, y, dx, dy)
    local item, pos = self:errget(key)
    return item.collider:intersectsRay(x, y, dx, dy)
end

function system:queryPoint(x, y, filter)
    filter = filter or function () return true end
    for i, item in pairs(self.items) do
        if item.collider:contains(x, y) and filter(vec2(x, y), item.key) then
            return true
        end
    end
    return false
end

function system:normalCols(collider, filter, callback)
    filter = filter or function () return true end
    callback = callback or function () end
    for i, item in pairs(self.items) do
        if item.key ~= collider.item.key then
            local is_col, dx, dy = self:collidesWith(item.key, collider)
            if is_col and filter(collider.item.key, item.key, vec2(-dx, -dy)) then
                collider:move(-dx, -dy)
                callback(collider.item.key, item.key, vec2(-dx, -dy))
                if not self:hasItem(collider.item.key) then return end
            end
        end
    end
end

function system:move(key, dx, dy, filter, callback)
    local item, pos = self:errget(key)
    item.collider:move(dx, dy)
    self:normalCols(item.collider, filter, callback)
end

function system:moveTo(key, x, y, filter, callback)
    local item, pos = self:errget(key)
    item.collider:moveTo(x, y)
    self:normalCols(item.collider, filter, callback)
end

return system