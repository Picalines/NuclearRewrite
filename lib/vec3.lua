local vec3 = class()

function vec3:new(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end

function vec3:clone()
    return vec3(self.x, self.y, self.z)
end

function vec3:dist(v)
    return math.sqrt((v.x - self.x) ^ 2 + (v.y - self.y) ^ 2 + (v.z - self.z) ^ 2)
end

--function vec3:angle(v)
--    v = v or vec3()
--    return math.atan2( v.x - self.x, v.y - self.y )
--end

function vec3:len()
    return math.sqrt( self.x ^ 2 + self.y ^ 2 + self.z ^ 2 )
end

function vec3:unpack()
    return self.x, self.y, self.z
end

--meta
function vec3:__add(v)
    return vec3(self.x + v.x, self.y + v.y, self.z + v.z)
end

function vec3:__sub(v)
    return vec3(self.x - v.x, self.y - v.y, self.z - v.z)
end

function vec3:__div(n)
    return vec3(self.x / n, self.y / n, self.z / n)
end

function vec3:__mul(n)
    return vec3(self.x * n, self.y * n, self.z * n)
end

function vec3:__unm()
    return vec3(self.x * -1, self.y * -1, self.z * -1)
end

function vec3:__pow(n)
    return vec3(self.x ^ n, self.y ^ n, self.z ^ n)
end

function vec3:__mod(n)
    return vec3(self.x % n, self.y % n, self.z % n)
end

function vec3:__eq(v)
    return (self.x == v.x and self.y == v.y and self.z == v.z)
end

function vec3:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

function vec3:__concat(b)
    return tostring(self) .. b
end

return vec3