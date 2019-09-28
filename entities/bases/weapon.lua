local weapon = class(entitySystem.entity)

function weapon:__tostring()
    return 'Weapon'
end

function weapon:new()
    self.owner = nil

    self.pos = vec2()
    self.aim = vec2()

    self.ammo   = {
        total     = 5,
        maxtotal  = 10,
        holder    = 5,
        maxholder = 5
    }

    self.shooting = {
        time  = 0,
        speed = 0.3
    }

    self.reloading = {
        time  = 0,
        speed = 0.01
    }

    self.hand_ofset = 0
    self.projectile = 'lazer_bullet'
    self.auto = false

    self.info = {
        name            = self.type_id,
        description     = "",
        namecolor       = color(1, 1, 1, 1),
        descolor        = color(0.8, 0.8, 0.8, 1),
        ammo_bar_color  = color(1, 0.7, 0, 1),
        ammo_bar_sprite = Assets.icons.bullet_ammo
    }
end

function weapon:draw()
    love.graphics.draw(self.sprite,
        self.pos.x-self.hitbox.sx/2+5,
        self.pos.y-self.hitbox.sy/2,
        math.atan2(self.aim.y, self.aim.x), 1, math.sign(self.aim.x), self.hand_ofset
    )
end

function weapon:setOwner(entity)
    assert(entity:is(Mob), 'weapon owner is not a Mob!')
    self.slot_index = #entity.weapons+1
    self.owner = entity
    entity.weapons[#entity.weapons+1] = self
    while self.__system:hasEntity(self) do
        self.__system:removeEntity(self)
    end
    entity.weapons[#entity.weapons]:on_pickup()
end

function weapon:drop()
    if self.owner then
        local new = self.owner.__system:createEntity(self.__class, self.owner.room, self.pos:clone())
        table.remove(self.owner.weapons, self.slot_index)

        new.ammo  = self.ammo
        new.pos.x = new.pos.x - new.hitbox.sx / 4

        new.pos.y = new.pos.y - 8
        TIME:tween(0.7, new.pos, { y = new.pos.y+16 }, 'bounce')

        new:on_drop()
    end
end

function weapon:canShoot()
    return self.owner and self.projectile and self.ammo.holder > 0 and self.shooting.time == 0 and self.reloading.time == 0 
end

function weapon:needReload()
    return self.ammo.holder == 0
end

function weapon:shoot()
    if self:canShoot() then
        self.owner.__system:createEntity(self.projectile, self.owner.room, self.pos, self.owner, self.aim:clone())
        self.ammo.holder = self.ammo.holder - 1
        self.ammo.holder = math.clamp(0, self.ammo.holder, self.ammo.maxholder)
        self.shooting.time = self.shooting.speed
        self:on_shoot()
        if self:needReload() then self:reloadHolder() end
    elseif self.owner and self.ammo.total == 0 then
        self:on_no_ammo()
    end
end

function weapon:reloadHolder()
    if self.reloading.time > 0 or self.ammo.holder == self.ammo.maxholder or self.ammo.total == 0 then
        return
    end
    while self.ammo.holder < self.ammo.maxholder and (self.ammo.total or 1) > 0 do
        if self.ammo.total then
            self.ammo.total = self.ammo.total - 1
        end
        self.ammo.holder = self.ammo.holder + 1
    end
    self.reloading.time = self.reloading.speed
    self:on_reload()
end

function weapon:fullReload(c)
    self.ammo.total = math.clamp(0, self.ammo.total + c, self.ammo.maxtotal)
end

function weapon:on_shoot()   self.hand_ofset = 3 end
function weapon:on_reload()  self.hand_ofset = 5 end
function weapon:on_no_ammo() self.hand_ofset = -5 end
function weapon:on_pickup()  end
function weapon:on_drop()    end

function weapon:on_switch(b) --b is true when switch on it, else false
    if b then
        self.hand_ofset = 7
    end
end

function weapon:cooldownsUpdate(dt)
    self.shooting.time  = math.clamp(0, self.shooting.time  - dt,  self.shooting.speed)
    self.reloading.time = math.clamp(0, self.reloading.time - dt, self.reloading.speed)
end

function weapon:setOwnerPosAim()
    if self.owner then
        self.pos.x = self.owner.pos.x + self.owner.weapon_hold_dx
        self.pos.y = self.owner.pos.y + self.owner.weapon_hold_dy
        self.aim = self.owner.aim:clone()
    end
end

function weapon:updateInHands(dt)
    self.hand_ofset = self.hand_ofset + -self.hand_ofset * 0.2
    self:cooldownsUpdate(dt)
    self:setOwnerPosAim()
end

function weapon:update(dt)
    self:updateInHands(dt)
end

function weapon:setInfo(inf)
    for i, c in pairs(inf) do
        assert(self.info[i] ~= nil, i..' weapon info component is not exists!')
        assert(type(self.info[i]) == type(c), i..' weapon info component type must be ' .. type(self.info[i]) .. '!')
        self.info[i] = c
    end
end

return weapon