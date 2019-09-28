local liquid = class(Mob)

liquid.type_id = 'liquid'

function liquid:on_spawn(room, pos, size, vel)
    self.room = room
    self.pos  = pos
    self.vel  = vel or self.vel

    size      = size or vec2(9, 9)
    self.size = vec2()

    self.color         = color(0.5, 0.5, 0.5, 1)
    self.sprite        = Assets.particles["liquid" .. math.random(1, 3)]
    self.sprite_scaleX = 0
    self.sprite_scaleY = 0

    self.life = 2
    self.hitbox.sy = -self.pos.y

    local oldup = self.update
    local ssx, ssy = self.sprite:getWidth(), self.sprite:getHeight()
    self.update = function () end
    TIME:tween(0.4, self, {size = {x = size.x, y = size.y}, sprite_scaleX = size.x / ssx, sprite_scaleY = size.y / ssy}, 'linear', function ()
        self.update = oldup
    end)

end

function liquid:effect(other) end

--function liquid:collide_filter(other)
--    if other.isTile then
--        return 'slide'
--    end
--    return 'cross'
--end

function liquid:update(dt)
    --move by vel
    self:move(self.vel.x, self.vel.y)
    self.vel = self.vel + -(self.vel / 1.5)
    --effect
    local items, len = ROOM.physics:queryRect(self.pos.x - self.size.x/2, self.pos.y - self.size.y/2, self.size.x, self.size.y, function () return 'cross' end)
    local can_eff = true
    for i, item in pairs(items) do
        if item.is and item:is(liquid) then
            can_eff = false
            break
        end
    end
    if can_eff then
        for i, item in pairs(items) do
            if item.is and item:is(Mob) and (not item:is(liquid)) then
                self:effect(item)
            end
        end
    end
    --life
    self.life = self.life - dt
    if self.life <= 0 then
        function self:update() end
        TIME:tween(0.8, self, {size = {x = 0, y = 0}, sprite_scaleX = 0, sprite_scaleY = 0, color = {a = 0}}, 'linear', function ()
            self:destroy()
        end)
    end
end

function liquid:draw()
    love.graphics.setColor(self.color)
    love.graphics.draw(self.sprite, self.pos.x - self.size.x/2, self.pos.y - self.size.y/2, 0, self.sprite_scaleX, self.sprite_scaleY)
end

return liquid