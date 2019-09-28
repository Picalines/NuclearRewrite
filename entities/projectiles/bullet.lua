local bullet = class(Projectile)

bullet.type_id = 'bullet'

bullet.color = color(0.88, 0.88, 0.87, 1)

function bullet:on_spawn(room, pos, spawner, vel)
    self.room    = room
    self.spawner = spawner

    local size = vec2(5, 4)
    self.pos     = (pos or vec2()) - size / 2
    self.vel     = (vel or vec2()) * 6
    
    self:load_physics(self.room.physics, {
        sx = size.x, sy = size.y
    })

end

function bullet:update(dt)
    if ROOM.physics:hasItem(self) then
        ROOM.physics:setRotation(self, math.atan2(self.vel.y, self.vel.x))
    end
    self:move(self.vel.x * dt * 60, self.vel.y * dt * 60)
end

function bullet:on_hit(cols)
    self:unload_physics()
    self.vel = -self.vel
    self.hitbox.sx, self.hitbox.sy = self.hitbox.sx/2, self.hitbox.sy/2
    TIME:tween(0.1, self.vel, {x = 0, y = 0}, 'linear', function ()
        self:destroy()
    end)
end

function bullet:on_mob_hit(mob)
    mob:updateHp(-self.damage)
    mob.vel = mob.vel + self.vel
    function self:on_mob_hit() end
end

function bullet:draw()
    love.graphics.push()
    love.graphics.translate(self.pos.x+self.hitbox.sx/2, self.pos.y+self.hitbox.sy/2)
    love.graphics.rotate( math.atan2(self.vel.y, self.vel.x) )
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', -self.hitbox.sx/2, -self.hitbox.sy/2, self.hitbox.sx, self.hitbox.sy)
    love.graphics.setColor(self.color.r - 0.1, self.color.g - 0.1, self.color.b - 0.1, 1)
    love.graphics.rectangle('line', -self.hitbox.sx/2, -self.hitbox.sy/2, self.hitbox.sx, self.hitbox.sy)
    love.graphics.pop()
end

return bullet