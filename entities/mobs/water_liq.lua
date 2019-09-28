local water_liquid = class(EntityClasses.liquid)

water_liquid.type_id = 'water_liquid'

function water_liquid:on_spawn(...)
    water_liquid.__parent.on_spawn(self, ...)
    self.color = color(0, 0.6, 0.85)
end

function water_liquid:effect(other)
    other.vel = other.vel + vec2(math.rad(other.vel.x), math.rad(other.vel.y))
end

return water_liquid