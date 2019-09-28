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

function params:projectile(p)
    assertType('projectile', 'string', p)
    self.projectile = p
end

function params:info(i)
    assertType('info', 'table', i)
    if i.ammo_bar_sprite and type(i.ammo_bar_sprite) ~= 'userdata' then
        local old_sprite = self.sprite
        params.sprite(self, i.ammo_bar_sprite)
        i.ammo_bar_sprite = self.sprite
        self.sprite = old_sprite
    end
    self:setInfo(i)
end

return params