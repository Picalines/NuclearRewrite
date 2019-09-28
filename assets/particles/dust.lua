local dust = class(particleSystem.particle)

function dust:on_emit()
    self.sprite = Assets.particles['dust_img' .. math.random(1, 3)]
    self.sx, self.sy = self.sprite:getDimensions()
    self.rot = 0
    self.speed = math.random(1, 3)
    self.sx = (self.life / self.time)
    self.sy = (self.life / self.time)
end

function dust:on_update(dt)
    self.rot = self.rot + dt * self.speed
    self.sx = (self.life / self.time)
    self.sy = (self.life / self.time)
end

function dust:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.sprite, self.x, self.y, self.rot, self.sx, self.sy, self.sprite:getWidth() * self.sx, self.sprite:getHeight() * self.sy)
end

return dust