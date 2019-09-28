local lazer_bullet = class(EntityClasses.bullet)

lazer_bullet.type_id = 'lazer_bullet'

lazer_bullet.color = color(0.4, 0.9, 0.6, 1)

function lazer_bullet:on_spawn(...)
    lazer_bullet.__parent.on_spawn(self, ...)
    self.vel = self.vel / 1.5
end

function lazer_bullet:on_hit(cols)
    self:unload_physics()
    self.vel = -self.vel
    for i = 1, 3 do
        ROOM.particles:emit(Assets.particles.lazer_part, self.pos.x, self.pos.y, self.vel.x / 2 + math.random(-1, 1), self.vel.y / 2 + math.random(-1, 1), nil, self.color:clone())
    end
    self.hitbox.sx, self.hitbox.sy = self.hitbox.sx/2, self.hitbox.sy/2
    TIME:tween(0.1, self.vel, {x = 0, y = 0}, 'linear', function ()
        self:destroy()
    end)
end

return lazer_bullet