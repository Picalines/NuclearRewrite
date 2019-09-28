local lazer = class(Projectile)
lazer.type_id = 'lazer'

function lazer:on_spawn(room, pos, spawner, vel)
    self.room    = room
    self.spawner = spawner

    self.pos = pos
    self.ang = vel

    self.width = 6

    --link with other side
    local pos2 = vec2()
    local limit, c = 600, 0
    local filter = function (p, other)
        return self:collide_filter(other)
    end
    while (not ROOM.physics:queryPoint(self.pos.x + pos2.x, self.pos.y + pos2.y, filter)) and (c <= limit) do
        pos2 = pos2 + vel * 3
        c = c + 1
        if not math.inrange2d(self.pos.x + pos2.x, self.pos.y + pos2.y, 0, 0, self.room.tiledmap.real_width, self.room.tiledmap.real_height) then
            break
        end
    end
    local m = self.pos + pos2
    self.pos = self.pos:mid(m) + vec2(-self.width/2, -pos2:len()/2)

    self:load_physics(self.room.physics, {
        sx = self.width, sy = pos2:len(), rotation = math.atan2(self.ang.y, self.ang.x) + math.atan(90)
    })

    self.color = EntityClasses.lazer_bullet.color:clone()

    TIME:tween(0.3, self, {color = {a = 0.3}, width = 0}, 'linear', function ()
        self:destroy()
    end)

    for sh, _ in pairs(self.physics:collisions(self)) do
        if sh.item.key.is and sh.item.key:is(Mob) and sh.item.key ~= self.spawner then
            self:on_mob_hit(sh.item.key)
        end
    end

end

function lazer:on_mob_hit(mob)
    mob:updateHp(-self.damage)
    mob.vel = self.ang * 4
    self:unload_physics()
end

function lazer:draw()
    love.graphics.push()
    love.graphics.translate(self.pos.x+self.width/2, self.pos.y+self.hitbox.sy/2)
    love.graphics.rotate( math.atan2(self.ang.y, self.ang.x) + math.atan(90) )
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', -self.width/2, -self.hitbox.sy/2, self.width, self.hitbox.sy)
    love.graphics.setColor(self.color.r - 0.1, self.color.g - 0.1, self.color.b - 0.1, self.color.a)
    love.graphics.rectangle('line', -self.width/2, -self.hitbox.sy/2, self.width, self.hitbox.sy)
    love.graphics.pop()
end

return lazer