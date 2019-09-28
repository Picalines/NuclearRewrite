local spaceship_trail = class(particleSystem.particle)

function spaceship_trail:on_emit()
    self.sx = math.random(3, 5)
    self.sy = self.sx
    self.color = color((153+math.random(0,-50))/255, (102+math.random(0,-50))/255, (255+math.random(0,-80))/255)
end

function spaceship_trail:draw()
    self.color.a = ((self.life*2) / self.time)
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.sx, self.sy)
end

return spaceship_trail