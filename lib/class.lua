local function class(parent)
    local c = {}

    --load parameters from parent class
    if type(parent) == 'table' then
        for k, v in pairs(parent) do
            c[k] = v
        end
        c.__parent = parent
    end

    c.__index = c
    local mt = {}

    mt.__call = function (self, ...)
        local obj = {} --new object
        setmetatable(obj, c) --load metamethods from class
        
        obj.__class = c

        if self.new then
            self.new(obj, ...)
        elseif parent and parent.new then
            parent.new(obj, ...)
        end

        return obj
    end

    function c.is(self, otherClass)
        local p = getmetatable(self)
        while p do
            if p == otherClass then return true end
            p = p.__parent
        end
        return false
    end
    
    return setmetatable(c, mt)
end

return class