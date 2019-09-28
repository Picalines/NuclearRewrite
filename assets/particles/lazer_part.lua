local lazer_part = class(particleSystem.particle)

function lazer_part:on_emit(clr)
    self.color_1 = clr or EntityClasses.lazer_bullet.color:clone()
    self.color_2 = color(self.color_1.r - 0.1, self.color_1.g - 0.1, self.color_1.b - 0.1)
    self.sx, self.sy = 4, 2
    self.life = math.random(1, 6) / 10
end

function lazer_part:draw()
    self.color_1.a = (self.life / self.time)
    self.color_2.a = self.color_1.a
    love.graphics.push()
    love.graphics.translate(self.x+self.sx/2, self.y+self.sy/2)
    love.graphics.rotate( math.atan2(self.vy, self.vx) )
    love.graphics.setColor(self.color_1)
    love.graphics.rectangle('fill', -self.sx/2, -self.sy/2, self.sx, self.sy)
    love.graphics.setColor(self.color_2)
    love.graphics.rectangle('line', -self.sx/2, -self.sy/2, self.sx, self.sy)
    love.graphics.pop()
end

return lazer_part