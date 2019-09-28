local water_blob = class(Mob)

water_blob.type_id = 'water_blob'

function water_blob:on_spawn(room, pos)
    self.room = room
    self.pos  = pos

    self.hp = {
        count = 3,
        max   = 3
    }

    self.anim = Animation(Assets.entities.water_blob)
    self.anim:addType('run', 0, 0, 16, 16, 0.06, 4):setCallback{
        onNewFrame = function (t)
            ROOM.entities:createEntity('water_liquid', ROOM, self.pos + vec2(self.hitbox.sx/2, self.hitbox.sy/2), vec2(9, 9))
        end
    }
    self.anim:addType('spawn', 0, 16, 16, 16, 0.1, 6)
    self.anim:addType('death', 0, 32, 16, 16, 0.15, 4):setStyle({loop = false}):setCallback{
        onNewFrame = function (t)
            ROOM.entities:createEntity('water_liquid', ROOM, self.pos + vec2(self.hitbox.sx/2, self.hitbox.sy/2), vec2(9, 9))
        end,
        onEnd = function (t)
            ROOM.entities:createEntity('water_liquid', ROOM, self.pos + vec2(self.hitbox.sx/2, self.hitbox.sy/2), vec2(32, 32))
            self:destroy()
        end
    }

    self.anim:setType('spawn')
    local oldup = self.update
    function self:update(dt)
        self.anim:update(dt)
        if self.anim:getType().frame == 6 then
            self.update = oldup
            self.anim:setType('run')
            self:load_physics(self.room.physics, {
                sx = 16, sy = 16
            })
        end
    end

    self.aim_seed  = math.randomFloat(3, 5)
    self.flow_time = 0

end

function water_blob:update(dt)
    --move and update velocity
    self:move(self.aim.x*1.3 + self.vel.x, self.aim.y*1.3 + self.vel.y)
    self.vel = self.vel + -(self.vel / 3)

    --aim update
    --local p = self:getNearestEntity('plant', 64)
    p = p or Player
    local ax, ay = p:center().x + self.aim.x, p:center().y + self.aim.y
    ax = ax + math.sin(love.timer.getTime()*self.aim_seed) * 48
    ay = ay + math.cos(love.timer.getTime()*self.aim_seed) * 48

    ax, ay = self:pAimOn(ax, ay)
    self.aim.x = ax + (self.aim.x - ax) * 0.9
    self.aim.y = ay + (self.aim.y - ay) * 0.9
    if p.type_id == 'plant' then
        self.aim = -self.aim
    end

    --if math.random(0, 100) == 1 then
    --    self.aim_seed = math.clamp(2.5, self.aim_seed + math.randomFloat(-1, 1), 10)
    --end

    --update animation
    self.anim:update(dt)
end

function water_blob:draw()
    local d = -math.clamp(-1, math.sign(self.aim.x), 0)*self.hitbox.sx + 1 * -math.sign(self.aim.x)
    self.anim:draw(self.pos.x + d, self.pos.y, 0, math.sign(self.aim.x), 1)
end

function water_blob:on_death()
    self.vel = self.vel * 1.4
    self.anim:setType('death')
    function self:update(dt)
        self:move(self.vel.x, self.vel.y)
        self.vel = self.vel + -(self.vel / 8)
        self.anim:update(dt)
    end
    function self:on_death() end
end

function water_blob:on_collide(cols)
    if cols.other.isTile then
        self.vel.x = cols.normal.x * 5
        self.vel.y = cols.normal.y * 5
    end
end

return water_blob