local params = {}

local function assertType(name, need, value)
    if type(need) == 'table' then
        for _, n in pairs(need) do
            if type(value) == n then
                return
            end
        end
        assertType(name, need[1], value)
    else
        assert(type(value) == need, tostring(name) .. ' parameter type must be ' .. need .. ' (found: ' .. type(value) .. ')')
    end
end

local function buildCode(s)
    if type(s) == 'table' then
        s = 'return function (self) ' .. table.concat(s, ' ') .. ' end'
    else
        s = 'return function (self) ' .. tostring(s) .. ' end'
    end
    local s, msg = load(s)
    if not s then
        error('error on compiling json entity parameter: ' .. msg)
    else
        return s()
    end
end

function params:sprite(s)
    assertType('srpite', 'string', s)
    if s:find('Assets: ') then
        self.sprite = load('return Assets.' .. s:sub(9, #s):gsub('/', '.'))()
    else
        self.sprite = love.graphics.newImage(s)
    end
end

function params:hitbox(t)
    assertType('hitbox', 'table', t)
    self:load_physics(self.room.physics, t)
end

function params:animation(t)
    assertType('animation', 'table', t)
    local old_sprite = self.sprite
    params.sprite(self, t.atlas)
    self.animation = Animation(self.sprite, unpack(t.frame_size))
    self.sprite = old_sprite
    local _init_
    for name, typ in pairs(t.types) do
        if name == '_init_' then
            _init_ = typ
        else
            self.animation:addType(name, typ.frames[1], typ.frames[2], typ.style)
        end
    end
    if _init_ then
        self.animation:setType(_init_)
    end
end

function params:hp(t)
    assertType('hp', 'table', t)
    self.hp = {
        count = t.count or inf,
        max   = t.max   or inf
    }
end

function params:patterns(t)
    assertType('patterns', 'table', t)
    local _init_
    for name, p in pairs(t) do
        if name == '_init_' then
            _init_ = p
        else
            local f = buildCode(p.actions)
            self:addPattern(name, f)
        end
    end

    function self:on_patternChange(new)
        for name, p in pairs(t) do
            if name == new then
                if p.animation then
                    assert(self.animation ~= nil, "can't set animation type by pattern (animation == nil)")
                    self.animation:setType(p.animation)
                end
                if p.next then
                    if p.next.after then
                        if type(p.next.after) == 'number' then
                            ROOM.Time:after(p.next.after, function () if not self.dead then self:setPattern(p.next.name) end end)
                        else
                            ROOM.Time:after(buildCode(p.next.after)(), function () if not self.dead then self:setPattern(p.next.name) end end)
                        end
                    end
                    if p.next.action then
                        buildCode(p.next.action)(self)
                    end
                end
            end
        end
    end

    if _init_ then
        self:setPattern(_init_)
    end
end

function params:weapon(w)
    assert(EntityClasses[w] ~= nil, "can't find weapon " .. tostring(w) .. " class")
    self.room.entities:createEntity(w, self.room, self.pos:clone())
    self:weaponPickup()
end

function params:weapon_hold(t)
    self.weapon_hold_dx = t.dx or 0
    self.weapon_hold_dy = t.dy or 0
end

function params:on_death(f)
    assertType('on_death', {'function', 'table'}, f)
    f = buildCode(f)
    self.on_death = f
end

function params:on_damage(f)
    assertType('on_damage', {'function', 'table'}, f)
    f = buildCode(f)
    self.on_damage = f
end

function params:on_heal(f)
    assertType('on_heal', {'function', 'table'}, f)
    f = buildCode(f)
    self.on_heal = f
end

return params