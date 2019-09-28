local mob = class(entitySystem.entity)

function mob:__tostring()
    return 'Mob'
end

function mob:new()
    self.sprite = Assets.missing
    self.sprite_tint = color(1, 1, 1, 1)

    self.hp = {
        count = inf,
        max   = inf
    }

    self.dead = false

    self.weapons = {}
    self.CurrentWeapon = 1
    self.weapon = nil

    self.aim = vec2()

    self.weapon_hold_dx = 0
    self.weapon_hold_dy = 0

    self.patterns = {}
    self.pattern  = ''
end

function mob:draw()
    love.graphics.setColor(self.sprite_tint)
    if self.animation then
        self.animation:draw(self.pos.x, self.pos.y, 0, math.sign(self.aim.x), 1, math.clamp(0, self.hitbox.sx * -math.sign(self.aim.x), self.hitbox.sx), 0)
    else
        love.graphics.draw(self.sprite, self.pos.x, self.pos.y, 0, math.sign(self.aim.x), 1, math.clamp(0, self.hitbox.sx * -math.sign(self.aim.x), self.hitbox.sx), 0)
    end
    self:weaponsDraw()
end

function mob:update(dt)
    self:move(self.vel.x, self.vel.y)
    self.vel = self.vel - self.vel / 3
    self:patternsUpdate(dt)
    self:weaponsUpdate(dt)
    if self.animation then
        self.animation:update(dt)
    end
end

mob.weapons = {}
function mob:weaponsUpdate(dt)
    if not self.weapons[self.CurrentWeapon] then
        self.weapon = nil
        return
    end
    self.weapons[self.CurrentWeapon].owner = self
    self.weapons[self.CurrentWeapon]:update(dt)
    self.weapon = self.weapons[self.CurrentWeapon]
end

function mob:weaponsDraw()
    if not self.weapons[self.CurrentWeapon] then return end
    self.weapons[self.CurrentWeapon]:draw()
end

function mob:changeWeapon(w)
    local old = self.CurrentWeapon
    if w == 'next' then
        self.CurrentWeapon = self.CurrentWeapon + 1
        if not self.weapons[self.CurrentWeapon] then
            self.CurrentWeapon = 1
        end
    elseif type(w) == 'number' or tonumber(w) then
        self.CurrentWeapon = math.clamp(1, tonumber(w), #self.weapons)
    end
    self.weapon = self.weapons[self.CurrentWeapon]
    if self.CurrentWeapon ~= old then
        self.weapons[old]:on_switch(false)
        self.weapons[self.CurrentWeapon]:on_switch(true)
    end
end

function mob:weaponPickup()
    local weap = self:getNearestEntity(Weapon, 32)
    if weap then
        weap:setOwner(self)
        self.CurrentWeapon = #self.weapons
        if self.weapon then
            self.weapon:on_switch(false)
        end
        self.weapon = self.weapons[self.CurrentWeapon]
        return true
    else
        return false
    end
end

function mob:giveWeapon(name)
    assert(EntityClasses[name] ~= nil and EntityClasses[name]():is(Weapon), "can't find " .. tostring(name) .. " weapon (or it's not a Weapon)")
    local weap = ROOM.entities:createEntity(name, ROOM, self.pos:clone())
    weap:setOwner(self)
    if self.weapon then
        self.weapon:on_switch(false)
    end
    self.CurrentWeapon = #self.weapons
    self:weaponsUpdate(DeltaTime)
end

function mob:updateHp(count, type, trigger)
    count = count or 0
    type  = type or 'count'
    assert(type == 'count' or type == 'max', "Hp type to upadte must be 'count' or 'max'")
    if trigger == nil then trigger = true end

    if count == 0 then return end
    self.hp[type] = self.hp[type] + count

    if type == 'count' then
        if count < 0 then
            if trigger then self:on_damage(count) end
            if self.hp.count <= 0 then
                self.dead = true
                self:on_death()
            end
        elseif count > 0 then
            if trigger then
                self:on_heal(count)
            end
        end
    end

    self.hp.count = math.clamp(0, self.hp.count, self.hp.max)
end

function mob:damage(count)
    count = count or 1
    self:updateHp(-math.abs(count))
    --self:on_damage(-math.abs(count))
end

function mob:heal(count)
    count = count or 1
    self:updateHp(math.abs(count))
    --self:on_heal(math.abs(count))
end

function mob:on_damage(count)          end
function mob:on_heal(count)            end
function mob:on_death() self:destroy() end --calls when entitie.hp <= 0 

function mob:on_room_move(dx, dy) return true end --if false then cancel moving
function mob:on_new_room(dx, dy) end 

function mob:pAimOn(x, y)
    x, y = x or 0, y or 0
    if type(x) == 'table' then
        y = x.y
        x = x.x
    end
    local ang = math.atan2(
        x - (self.pos.x + self.hitbox.sx/2),
        y - (self.pos.y + self.hitbox.sy/2)
    )
    return math.sin(ang), math.cos(ang)
end

function mob:aimOn(x, y)
    self.aim.x, self.aim.y = self:pAimOn(x, y)
end

function mob:addPattern(name, f)
    assert(self.patterns[name] == nil, tostring(name) .. ' pattern is already exists! (type_id: ' .. self.type_id .. ')')
    assert(type(f) == 'function', 'pattern type must be function! (pattern: ' .. tostring(name) .. ', type_id: ' .. self.type_id .. ')')
    self.patterns[name] = f
end

function mob:setPattern(s)
    if (s == 'random') or (type(s) == 'boolean' and s) then
        self.pattern = nil
        while self.pattern == nil do
            for i, p in pairs(self.patterns) do
                if math.random(0,1) == 1 then
                    self.pattern = i
                    break
                end
            end
        end
    else
        self.pattern = s
    end
    self:on_patternChange(self.pattern)
end

function mob:patternsUpdate(dt)
    if self.patterns[self.pattern] then
        local v = self.patterns[self.pattern](self, dt)
        if v then
            self:setPattern(v)
        end
    end
end

function mob:on_patternChange(newp) end

return mob