local entity = class()

function entity:__tostring()
    return 'entitySystem.entity'
end

function entity:on_spawn() end

function entity:new()
    self.vel  = vec2()
    self.pos  = vec2()

    self.hitbox = {
        dx = 0, dy = 0, sx = 16, sy = 16
    }
end

function entity:center()
    return vec2(self.pos.x + self.hitbox.sx/2, self.pos.y + self.hitbox.sy/2)
end

function entity:draw()          end
function entity:update(dt)      end

function entity:keypressed()    end
function entity:keyreleased()   end

function entity:mousepressed()  end
function entity:mousereleased() end

function entity:on_room_move() return true end --if false or nil then cancel moving
function entity:on_new_room() end

function entity:on_destroy() end --calls when entitie:destroy()

function entity:destroy(trigger)
    if (trigger == true) or (trigger == nil) then
        self:on_destroy()
    end
    self:unload_physics()
    self.__system:removeEntity(self)
    self.destroyed = true
end

function entity:load_physics(system, hitbox)
    assert(type(hitbox) == 'table', 'Second argument type in load_physics function bust be a table!')
    self.hitbox = {
        dx = 0, dy = 0, sx = 16, sy = 16, rotation = 0, scale = 1
    }
    for i, h in pairs(hitbox) do
        self.hitbox[i] = h
    end
    assert(system, 'physics is nil!')
    self.physics = system
    while self.physics:hasItem(self) do
        self.physics:remove(self)
    end
    self.physics:add(self, 'rectangle', self.pos.x+self.hitbox.dx, self.pos.y+self.hitbox.dy, self.hitbox.sx, self.hitbox.sy)
    if self.hitbox.rotation ~= 0 then
        self.physics:rotate(self, self.hitbox.rotation)
    end
    if self.hitbox.scale ~= 1 then
        self.physics:scale(self, self.hitbox.scale)
    end
end

function entity:unload_physics()
    if self.physics ~= nil then
        while self.physics:hasItem(self) do
            self.physics:remove(self)
        end
        self.physics = nil
    end
end

function entity:control_by_keyboard(w, s, a, d)
    local key, v = love.keyboard.isDown, vec2()
    if key(a or CONTROLS.walk.left)  then v.x = v.x - 1 end
    if key(d or CONTROLS.walk.right) then v.x = v.x + 1 end
    if key(w or CONTROLS.walk.up)    then v.y = v.y - 1 end
    if key(s or CONTROLS.walk.down)  then v.y = v.y + 1 end
    return v
end

function entity:cols_filter(other)
    if other.isTrigger then return true end
    if other.isDoor and self:is(Mob) then return false end
    if other.isDoor and self:is(Projectile) then return false end
    if other.collide_filter then return other.collide_filter(other, self) end
    if self.collide_filter  then return self.collide_filter(self, other) end
    if other.isTile then return true end
    return 
end

function entity:move(dx, dy, triggers)
    if self.physics == nil then
        self.pos = self.pos + vec2(dx, dy)
        self:on_move(dx, dy)
        return {}, 0
    else
        if triggers == nil then
            triggers = true
        end
        if (not self.destroyed) and self.physics and self.physics:hasItem(self) then
            local function on_collide(self, other)
                if other.isTrigger and triggers then other.__code(other, self) end
                if self.on_collide ~= nil then self:on_collide(other) end
            end
            self.physics:moveTo(self, self.pos.x + dx + self.hitbox.sx / 2, self.pos.y + dy + self.hitbox.sy / 2, entity.cols_filter, on_collide)
            if (not self.destroyed) and self.physics and self.physics:hasItem(self) then
                self.pos.x, self.pos.y = self.physics:center(self)
                self.pos.x = self.pos.x - self.hitbox.sx / 2
                self.pos.y = self.pos.y - self.hitbox.sy / 2
                self:on_move(dx, dy)
            end
        end
    end
end

function entity:on_move(dx, dy) end

function entity:getNearestEntity(type_id, radius)
    radius = radius or 16*1000
    local min, ent = radius * 2
    for i, m in pairs(self.room.entities.entities) do
        if (m.type_id == type_id or m:is(type_id)) and self.pos:dist(m.pos) <= radius then
            local dist = self.pos:dist(m.pos)
            if dist < min then
                min  = dist
                ent  = m
            end
        end
    end
    return ent
end

return entity