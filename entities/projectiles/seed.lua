local seed = class(EntityClasses.lazer_bullet)

seed.type_id = 'seed_bullet'

seed.color = color(0.7, 0.4, 0.3, 1)

function seed:on_spawn(...)
    seed.__parent.on_spawn(self, ...)
    self.vel = self.vel / 1.4
end

function seed:on_hit(obj)
    seed.__parent.on_hit(self, obj)
    if obj.type_id == 'plant' then
        obj:heal()
    end
end

function seed:on_mob_hit(mob)
    if mob.type_id == 'plant' then
        if math.random(0, 100) < 40 then
            mob:heal()
        end
    else
        mob:updateHp(-self.damage)
        mob.vel = mob.vel + self.vel
    end
end

return seed