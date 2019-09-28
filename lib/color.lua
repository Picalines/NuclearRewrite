local function color(r, g, b, a)
    local c = {
        r or 0, g or 0, b or 0, a or 1
    }

    local mt = {}
    function mt:__index(key)
        if key == 'r' then
            return self[1]
        elseif key == 'g' then
            return self[2]
        elseif key == 'b' then
            return self[3]
        elseif key == 'a' then
            return self[4]
        else
            return self[key]
        end
    end

    function mt:__newindex(key, value)
        if key == 'r' then
            rawset(self, 1, value)
        elseif key == 'g' then
            rawset(self, 2, value)
        elseif key == 'b' then
            rawset(self, 3, value)
        elseif key == 'a' then
            rawset(self, 4, value)
        else
            rawset(self, key, value)
        end
    end

    function c:get(...)
        local vs, r = {...}, {}
        if #vs == 0 then
            return self[1], self[2], self[3], self[4]
        end
        for i, v in pairs(vs) do 
            r[i] = self[v]
        end
        return unpack(r)
    end

    function c:clone()
        return color(self[1], self[2], self[3], self[4])
    end

    setmetatable(c, mt)
    return c
end

return color