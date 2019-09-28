local system  = class()
system.entity = love.filesystem.load("entities/bases/entity.lua")()

function system:new()
    self.entities = {}
end

local function ___uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function system:createEntity(eClass, ...)
    if type(eClass) == 'string' then
        --eClass = love.filesystem.load('entities/' .. eClass .. '.lua')() 
        assert(EntityClasses[eClass] ~= nil, "can't find EntityClasses." .. tostring(eClass) .. ' !')
        eClass = EntityClasses[eClass]
    end

    local newent = eClass()
    local p = newent.__parent
    while p do
        p.new(newent)
        p = p.__parent
    end
    function newent:__tostring()
        return self.type_id or 'nil'
    end
    newent:on_spawn(...)

    assert(newent:is(self.entity), tostring(newent) .. ' is not a entitySystem.entity!')

    assert(eClass.type_id ~= nil, 'entity ' .. tostring(eClass) .. ' must have type_id property!')

    newent.__system = self
    newent.uuid = ___uuid()

    self.entities[#self.entities+1] = newent
    return self.entities[#self.entities]
end

function system:removeEntity(ent)
    assert(type(ent) == 'table' and ent:is(self.entity), tostring(ent) .. ' is not a entitySystem.entity!')
    for i, e in pairs(self.entities) do
        if ent == self.entities[i] then
            table.remove(self.entities, i)
            return
        end
    end
    --error('entitySystem has not ' .. tostring(ent) .. ' entity')
end

function system:hasEntity(ent)
    assert(type(ent) == 'table' and ent:is(self.entity), tostring(ent) .. ' is not a entitySystem.entity!')
    for i, e in pairs(self.entities) do
        if ent == self.entities[i] then
            return true
        end
    end
    return false
end

function system:getEntity(type_id)
    for i, e in pairs(self.entities) do
        if e.type_id == type_id then
            return self.entities[i]
        end
    end
    return self.entities[#self.entities]
end

function system:update(dt)
    for i, e in pairs(self.entities) do
        e:update(dt)
    end
end

function system:draw()
    local ents = self.entities
    table.sort( ents, function (a, b)
        return not ((a.pos.y + a.hitbox.sy) >= (b.pos.y + b.hitbox.sy))
    end)
    for i, e in ipairs(ents) do
        love.graphics.setColor(1, 1, 1, 1)
        e:draw()
    end
end

function system:keypressed(key)
    for i, e in pairs(self.entities) do
        e:keypressed(key)
    end
end

function system:keyreleased(key)
    for i, e in pairs(self.entities) do
        e:keyreleased(key)
    end
end

function system:mousepressed(x, y, but)
    for i, e in pairs(self.entities) do
        e:mousepressed(x, y, but)
    end
end

function system:mousereleased(x, y, but)
    for i, e in pairs(self.entities) do
        e:mousereleased(x, y, but)
    end
end

return system