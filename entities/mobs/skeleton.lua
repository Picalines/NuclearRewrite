local skeleton = class(Mob)

skeleton.type_id = 'skeleton'

function skeleton:on_spawn(room, pos)
    self.room     = room
    self.pos      = pos
    --self.look_dir = -1

    self.anim = Animation(Assets.entities.skeleton)
    self.anim:addType('stand', 0, 0, 16, 16, 0.2, 4)
    self.anim:addType('walk',  0, 16, 16, 16, 0.15, 4)
    self.anim:addType('dead',  0, 32, 16, 16, 0.1, 4):setStyle{ loop = false }

    self.anim:setType('stand')

    self.hp = {
        count = 4,
        max   = 4
    }

    self:load_physics(self.room.physics, {
        sx = 16, sy = 16
    })

    self.pattern = 'walk'
    self.patterns.walk  = self.walk_pattern
    self.patterns.stand = self.stand_pattern
    self.patterns.dash  = self.dash_pattern

    self.dash_callback = 1
end

function skeleton:collide_filter() return 'slide' end

function skeleton:walk_pattern(dt)
    self.vel = self.vel + self.aim / 2
    if math.random(0, 100) < 5 then
        return 'stand'
    elseif self.dash_callback == 0 then
        return 'dash'
    end
end

function skeleton:stand_pattern(dt)
    if math.random(0, 100) < 10 then
        return 'walk'
    end
end

function skeleton:dash_pattern(dt)
    if (math.abs(self.vel.x) < 4) and (math.abs(self.vel.y) < 4) then
        self:setPattern('walk')
        self.anim:getType('walk').speed = 0.15
        return 'stand'
    end
end

function skeleton:on_patternChange(newp)
    if newp == 'walk' then
        self.anim:setType('walk')
        local map = ROOM.tiledmap.mapFile
        self:aimOn(math.random(0, map.width*map.tilewidth), math.random(0, map.height*map.tileheight))
    elseif newp == 'stand' then
        self.anim:setType('stand')
    elseif newp == 'dash' then
        self:aimOn(Player.pos)
        TIME:during(0.3, function ()
            self.vel = self.aim:clone() * 5
        end)
        self.anim:setType('walk')
        self.anim:getType('walk').speed = 0.05
        self.dash_callback = 3
    end
end

function skeleton:on_collide(cols)
    if self.pattern == 'walk' then
        self.aim.x = self.aim.x * -cols.normal.x
        self.aim.y = self.aim.y * -cols.normal.y
    elseif self.pattern == 'dash' then
        self.aim = -self.aim
        if cols.other.is and cols.other:is(Mob) and self.vel:len() > 4 then
            cols.other:updateHp(-1)
            cols.other.vel = cols.other.vel + self.vel * 3
        end
        self:setPattern('walk')
        self.anim:getType('walk').speed = 0.15
    end
end

function skeleton:update(dt)
    self:patternsUpdate(dt)
    self:move(self.vel.x, self.vel.y)
    self.vel = self.vel + -(self.vel / 3)
    self.dash_callback = math.clamp(0, self.dash_callback - dt, 5)
    self.anim:update(dt)
end

function skeleton:draw()
    love.graphics.setColor(1,1,1)
    local d = -math.clamp(-1, math.sign(self.aim.x), 0)*self.hitbox.sx
    self.anim:draw(self.pos.x+d, self.pos.y, 0, 1*math.sign(self.aim.x), 1)
end

function skeleton:on_death()
    self.anim:setType('dead')
    local t = self.anim:getType('dead')
    TIME:after(t.speed*t.maxFrames, function ()
        function self:update() end
        self.__parent = {}
    end)
    self.patterns = {}
    self.pattern  = ''
    function self:collide_filter()
        return false
    end
end

return skeleton