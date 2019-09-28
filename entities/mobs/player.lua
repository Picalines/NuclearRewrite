local player = class(Mob)

player.type_id = 'player'

function player:on_spawn(room, pos)
    self.pos  = pos or vec2()

    self.hp = {
        count = 5, max = 5
    }

    self.room = room
    self:load_physics(self.room.physics, {
        sx = 7, sy = 16
    })

    --old
    --1, 4
    --7, 12
    --13, 16

    --new
    --9, 12
    --1, 8
    --1, 4

    self.anim = Animation(Assets.entities.spaceman, 9, 16)
    self.anim:addType('stand', 9, 12, {speed = 0.2})
    self.anim:addType('walk', 1, 8, {speed = 0.1}, {
        onNewFrame = function (t, f)
            if f == 4 or f == 8 then
                ROOM.particles:emit(Assets.particles.dust,
                    Player.pos.x + Player.hitbox.sx/2,
                    Player.pos.y + Player.hitbox.sy - 1,
                    -Player.vel.x + math.random(-2, 2) / 8,
                    -Player.vel.y + math.random(-2, 2) / 8,
                    0.4
                )
            end
        end
    })
    self.anim:addType('dead', 1, 4, {speed = 0.2, loop = false})

    self.anim:setType('stand')

    self.weapon_hold_dx = self.hitbox.sx/2
    self.weapon_hold_dy = self.hitbox.sy/2+2

    room.entities:createEntity('pistol', room, self.pos:clone())
    self:weaponPickup()

    --acsess to self by global var
    _G.Player = self
end

function player:update(dt)
    --Moving by keyboard
    self.vel = self.vel + self:control_by_keyboard()
    self:move(self.vel.x * dt * 60, self.vel.y * dt * 60)
    self.vel = self.vel + -(self.vel / 2)

    --Animation types
    if love.keyboard.isDown(CONTROLS.walk.up, CONTROLS.walk.down, CONTROLS.walk.left, CONTROLS.walk.right) then
        self.anim:setType('walk')
    else
        self.anim:setType('stand')
    end

    local mvec = vec2(CAMERA:PointToWorld( CURSOR.x, CURSOR.y ))
    local angle = math.atan2(
        mvec.x - (self.pos.x + self.hitbox.sx/2),
        mvec.y - (self.pos.y + self.hitbox.sy/2)
    )
    self.aim.x, self.aim.y = math.sin(angle), math.cos(angle)

    --Animation
    self.anim:update(dt)

    --weapons
    self:weaponsUpdate(dt)

    --GUIs
    --hp bar
    GUI.hp_bar.max   = self.hp.max

    --weapon
    GUI:ammoBarUpdate(self.weapon)

    if self.weapon and self.weapon.auto and love.mouse.isDown(CONTROLS.weapon.shoot) then
        self.weapon:shoot()
    end

    --trigger room battle
    if (ROOM.type == 'monster_room' or ROOM.type == 'boss_room') or ROOM.cleared then
        if (not ROOM.cleared) and ROOM.doorsOpened then
            if table.count( self.physics:collisions(self) ) == 0 then
                ROOM:closeDoors()
            end
        end

        if ROOM.cleared and (not ROOM.doorsOpened) then
            ROOM:openDoors()
        end
    end

    --acsess to self by global var
    _G.Player = self
end

function player:draw()
    love.graphics.setColor(1, 1, 1)
    self.anim:draw(self.pos.x, self.pos.y, 0, math.sign(self.aim.x), 1, math.clamp(0, self.hitbox.sx * -math.sign(self.aim.x), self.hitbox.sx), 0)
    self:weaponsDraw()
end

function player:mousepressed(x, y, but)
    if self.weapon and not self.weapon.auto and but == CONTROLS.weapon.shoot then
        self.weapon:shoot()
    elseif self.weapon and but == CONTROLS.weapon.reload then
        self.weapon:reloadHolder()
    end
end

function player:keypressed(key)
    if key == CONTROLS.weapon['pickup/drop'] then
        local weap_pickuped = self:weaponPickup()
        if not weap_pickuped and self.weapon and self.CurrentWeapon > 1 then
            self.weapon:drop()
            self.CurrentWeapon = math.clamp(1, self.CurrentWeapon - 1, #self.weapons)
        elseif weap_pickuped then
            GUI:weaponInfoAnimPlay(self.weapon)
        end
    elseif key == CONTROLS.weapon.next then
        self:changeWeapon('next')
    elseif tonumber(key) then
        self:changeWeapon(key)
    end
end

function player:on_damage(c)
    CAMERA.shake = CAMERA.shake + 5
    GUI.hp_bar.count = self.hp.count
    local x, y = GUI.hp_bar.pos:unpack()
    TIME:during(0.3, function ()
        GUI.hp_bar.pos.x = x + math.random(-3, 3)
        GUI.hp_bar.pos.y = y + math.random(-3, 3)
    end)
    TIME:after(0.35, function ()
        GUI.hp_bar.pos.x, GUI.hp_bar.pos.y = x, y
    end)
end

function player:on_heal(c)
    GUI.hp_bar.count = self.hp.count
end

function player:on_death()
    if self.weapon then
        self.weapon:drop()
    end
    self.vel = self.vel * 2
    self.anim:setType('dead')
    function self:update(dt)
        self:move(self.vel.x, self.vel.y)
        self.vel = self.vel + -(self.vel / 4)
        self.anim:update(dt)
    end
    TIME:after(0.2*4, function ()
        function self:on_room_move() end
        function self:keypressed() end
        function self:mousepressed() end
        function self:on_damage() end
        function self:on_heal() end
        SCENES:get('GameScreen'):playerDeath()
    end)
    function self:on_death() end
end

return player
