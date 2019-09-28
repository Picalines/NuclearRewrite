local camera = class()

function camera:new()
    self.zoom   = 1
    self.pos    = vec2()
    self.smooth = 0
    self.shake  = 0
end

local function calc_shake(self)
    return math.random(-self.shake, self.shake)
end

function camera:set(x, y, z, sm)
    x  = x or self.pos.x
    y  = y or self.pos.y
    z  = z or self.zoom
    sm = sm or self.smooth
    self.pos.x = math.floor( x + (self.pos.x - x) * sm)
    self.pos.y = math.floor( y + (self.pos.y - y) * sm)
    self.shake = math.clamp(0, self.shake - 1, self.shake)
    love.graphics.push()
    love.graphics.scale(z)
    love.graphics.translate(-self.pos.x + WIDTH/2/z + calc_shake(self), -self.pos.y + HEIGHT/2/z + calc_shake(self))
end

function camera:unset()
    love.graphics.pop()
end

function camera:PointToWorld(x, y)
    x, y = x or 0, y or 0
    return self.pos.x + x / self.zoom - WIDTH/2/self.zoom, self.pos.y + y / self.zoom - HEIGHT/2/self.zoom
end

return camera