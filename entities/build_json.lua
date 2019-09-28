return function (json_data)
    assert(json_data.parent ~= nil, '"parent" entity class parameter is nil!')
    local parent = load('return ' .. tostring(json_data.parent))()
    assert(parent ~= nil, '"parent" entity class parameter is nil!')
    assert(parent():is(entitySystem.entity), 'entity "parent" class is not entity!')

    local ent_class = class(parent)
    ent_class.type_id = json_data.type_id

    local global_perent = parent
    while global_perent.__parent ~= entitySystem.entity do
        global_perent = global_perent.__parent
    end

    local params = love.filesystem.load('entities/json_params/' .. string.lower(tostring(global_perent())) .. '.lua')()
    local ignore = {
        "parent", "type_id", "comment"
    }

    local function check_ignore(k)
        for i, g in pairs(ignore) do
            if g == k then return true end
        end
        return false
    end

    for k, v in pairs(json_data) do
        if not check_ignore(k) then
            assert(params[k] ~= nil, '"' .. k .. '" parameter is not supported in ' .. json_data.parent .. ' entity classes!')
        end
    end

    function ent_class:on_spawn(room, pos, vel)
        if ent_class.__parent.on_spawn then
            ent_class.__parent.on_spawn(self, room, pos, vel)
        end
        self.room = room
        self.pos  = pos
        self.vel  = vel or vec2()
        for k, v in pairs(json_data) do
            if not check_ignore(k) then
                if params[k] ~= nil then
                    params[k](self, v)
                elseif self[k] ~= nil then
                    self[k] = v
                end
            end
        end
    end

    return ent_class
end