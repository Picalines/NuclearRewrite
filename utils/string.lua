function string.random(len, min, max)
    local s = ""
    for i = 1, len do
        s = s .. string.char(math.random(min, max))
    end
    return s
end

function string.replace(s, old, new)
    local b, e = s:find(old, 1, true)
    if b == nil then
        return s
    end
    while b do
        s = s:sub(1, b-1) .. new .. s:sub(e+1)
        b, e = s:find(old, 1, true)
    end
    return s
end

function string.move(s, dx)
    assert(type(s) == 'string', 'string expected, got ' .. type(s))
    dx = dx or 1
    if (dx == 0 or #s <= 1) then return s end
    for i = 1, dx do
        local ss, es = s:sub(0, #s-1), s:sub(#s, #s)
        s = es .. ss
    end
    return s
end

--stringMeta = getmetatable("")
--
--stringMeta.__add = function (self, other)
--    return self .. other
--end
--
--stringMeta.__sub = function (self, other)
--    return string.gsub(self, other, "")
--end
--
--stringMeta.__mul = function (self, val)
--    local s = ""
--    if val > 0 then
--        for i = 1, val do
--            s = s .. self
--        end
--    elseif val < 0 then
--        for i = 1, math.abs(val) do
--            s = s .. string.reverse(self)
--        end
--    end
--    return s
--end
--
--stringMeta.__div = function (self, val)
--    local s = self
--    s = string.sub(s, 0, #s/math.abs(val))
--    if val < 0 then s = string.reverse(s) end
--    return s
--end
--
--stringMeta.__index = function (self, index)
--    if type(index) ~= 'number' then
--        return string[index]
--    else
--        return string.sub(self, index, index)
--    end
--end