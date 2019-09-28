local vec2 = class()

function vec2:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

function vec2:clone()
    return vec2(self.x, self.y)
end

function vec2:dist(v)
    return math.sqrt((v.x - self.x) ^ 2 + (v.y - self.y) ^ 2)
end

function vec2:angle(v)
    v = v or vec2()
    return math.atan2( v.x - self.x, v.y - self.y )
end

function vec2:len()
    return math.sqrt( self.x*self.x + self.y*self.y )
end

function vec2:mid(v)
    v = v or vec2()
    return vec2((self.x + v.x) / 2, (self.y + v.y) / 2)
end

function vec2:unpack()
    return self.x, self.y
end

--meta
function vec2:__add(v)
    return vec2(self.x + v.x, self.y + v.y)
end

function vec2:__sub(v)
    return vec2(self.x - v.x, self.y - v.y)
end

function vec2:__div(n)
    return vec2(self.x / n, self.y / n)
end

function vec2:__mul(n)
    return vec2(self.x * n, self.y * n)
end

function vec2:__unm()
    return vec2(self.x * -1, self.y * -1)
end

function vec2:__pow(n)
    return vec2(self.x ^ n, self.y ^ n)
end

function vec2:__mod(n)
    return vec2(self.x % n, self.y % n)
end

function vec2:__eq(v)
    return (self.x == v.x and self.y == v.y)
end

function vec2:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ")"
end

function vec2:__concat(b)
    return tostring(self) .. b
end

return vec2