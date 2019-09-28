local projectile = class(entitySystem.entity)

function projectile:__tostring()
    return 'Projectile'
end

function projectile:new()
    self.spawner = nil
    self.damage  = 1
end

function projectile:collide_filter(other)
    if other ~= self.spawner then
        if (other.is and other:is(Mob) and not other.dead) or other.isTile then
            return true
        end
    end
    return false
end

function projectile:on_collide(obj)
    if obj.is ~= nil then
        if obj:is(Mob) and self.spawner ~= obj then
            self:on_mob_hit(obj)
        end
    end
    self:on_hit(obj)
end

function projectile:on_hit(obj)
    self:destroy()
end

function projectile:on_mob_hit(mob)
    mob:updateHp(-self.damage)
end

function projectile:on_room_move()
    self:destroy()
    return false
end

return projectile