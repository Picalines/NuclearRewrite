local system = class()

--[[particle class]]--
system.particle = class()

function system.particle:new(x, y, vx, vy, time, ...)
    self.x,  self.y  = x or 0, y or 0
    self.sx, self.sy = 2, 2
    self.vx, self.vy = vx or 0, vy or 0
    self.life = time or 1
    self.time = self.life
    self:on_emit(...)
end

function system.particle:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill', self.x - self.sx/2, self.y - self.sy/2, self.sx, self.sy)
end

function system.particle:update(dt)
    self.x, self.y = self.x + self.vx * dt * 60, self.y + self.vy * dt * 60
    self.life = self.life - dt
    if self.life <= 0 then
        self:destroy()
    else
        self:on_update(dt)
    end
end

function system.particle:destroy()
    for i, p in pairs(self.system.particles) do
        if self == self.system.particles[i] then
            self:on_destroy()
            table.remove(self.system.particles, i)
            return
        end
    end
end

function system.particle:on_emit() end
function system.particle:on_update(dt) end
function system.particle:on_destroy() end

--[[system class]]--
function system:new()
    self.particles = {}
end

function system:emit(part, ...)
    if not part.is then
        part = part[math.random(1, #part)]
    end
    local p = part(...)
    assert(p:is(system.particle), 'Object to emit is not a particle!')
    p.system = self
    table.insert(self.particles, p)
end

function system:draw()
    for i, p in pairs(self.particles) do
        p:draw()
    end
end

function system:update(dt)
    for i, p in pairs(self.particles) do
        p:update(dt)
    end
end

return system