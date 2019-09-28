local room = class(Scene)

room.name = 'room(0, 0)'

function room:load(pos, tiled_map, doors)

    _G.ROOM = self

    self.pos      = pos or vec2()
    self.name     = 'room'..tostring(self.pos)
    self.visited  = false
    self.reached  = false
    self.cleared  = true

    --libs
    self.physics   = physicsSystem(128) --HC physics
    self.render    = Renderer() --render lib
    self.camera    = Camera(0, 0, 1) --Camera
    self.Timer     = Timer.new() --Timer
    self.Time      = Timer.new() -- for mobs
    self.entities  = entitySystem() --entities
    self.particles = particleSystem() --particles
    self.tiledmap  = tiledmap(tiled_map, self) --tilemap

    --door ways
    self.doorsOpened = true
    self.doors = {
        right = false,
        left  = false,
        up    = false,
        down  = false,
        layer = 1
    }

    if doors then
        for i, group in pairs(self.tiledmap.objectgroups) do
            if group.properties.type == 'doors' then
                assert(type(group.properties.layer) == 'number', "object layer doors must have int type 'layer' property!")
                self.doors.layer = group.properties.layer
                for j, obj in pairs(group.objects) do
                    assert(obj.properties.way, "Door object must have string 'way' property!")
                    self.doors[obj.properties.way] = obj
                    if not doors[obj.properties.way] then
                        self.doors[obj.properties.way] = false
                    else
                        self.physics:add({isDoor = true, room = self}, 'rectangle', obj.x, obj.y, obj.width, obj.height)
                    end
                end
            end
        end
        for i, way in pairs(doors) do
            if (not self.doors[i]) and way == true then
                error('Not enough doors')
            end
        end
    end

    --room type
    local typ, slpos, bmpos = tiled_map, tiled_map:len(), 1
    while typ:sub(slpos, slpos) ~= '/' and slpos >= 1 do
        slpos = slpos - 1
    end
    while typ:sub(bmpos, bmpos) ~= '_' and bmpos <= typ:len() do
        bmpos = bmpos + 1
    end

    self.type = typ:sub(slpos+1, bmpos-1)
    for i, s in pairs{ {'s', 'start_room'}, {'m', 'monster_room'}, {'t', 'treasure_room'}, {'b', 'boss_room'} } do
        if self.type == s[1] then
            self.type = s[2]
            break
        end
    end

    if self.type == 'monster_room' or self.type == 'boss_room' then
        self.cleared = false
    end

    --break tiles were doors
    for i, door in pairs(self.doors) do
        if door ~= false and type(door) ~= 'number' then
            self.doors[i].old_tiles = {}

            for y = door.y / self.tiledmap.tileheight + 1, (door.y + door.height) / self.tiledmap.tileheight do
                for x = door.x / self.tiledmap.tilewidth + 1, (door.x + door.width) / self.tiledmap.tilewidth do
                    --self.doors[i].old_tiles[x+y*self.tiledmap.width+1] = self.tiledmap.layer[self.doors.layer].data[1][x+y*self.tiledmap.width+1]
                    local id = self.tiledmap:setTile(self.doors.layer, x, y, 0)
                    self.doors[i].old_tiles[#self.doors[i].old_tiles+1] = {
                        pos   = vec2(x, y),
                        layer = self.doors.layer,
                        id    = id
                    }
                end
            end

        end
    end

    --Render init
    self.render:add(0, function ()
        if PLAYING and Player then
            --local cw = vec2( self.camera:PointToWorld(CURSOR.x, CURSOR.y) )
            --local pp = Player:center()
            --self.camera:set(pp.x + (pp.x - cw.x) / -5, pp.y + (pp.y - cw.y) / -5)
            local pc = Player:center()
            self.camera:set(pc.x, pc.y, self.camera.zoom, 0.8)
        else
            self.camera:set(self.camera.pos.x, self.camera.pos.y, false)
        end
    end)

    for i, layer in pairs(self.tiledmap.layers) do
        assert(layer.properties.render_layer, "'render_layer' property in layer " .. tostring(layer.name) .. " is not found or nil! (" .. self.name .. ")")
        self.render:add(layer.properties.render_layer, function ()
            love.graphics.setColor(1, 1, 1, 1)
            self.tiledmap:drawTileLayer(i)
        end)
    end

    assert(self.tiledmap.properties.entities_render_layer, "'entities_render_layer' property in tiled map is not found or nil! (" .. self.name .. ")")
    self.render:add(self.tiledmap.properties.entities_render_layer, function ()
        self.particles:draw()
    end)

    self.render:add(self.tiledmap.properties.entities_render_layer+1, function()
        self.entities:draw()
    end)

    self.render:add(nil, function ()
        if DEBUG.showHitBoxes then
            love.graphics.setColor(1, 1, 1, 1)
            for i, item in pairs(self.physics.items) do
                self.physics:draw(item.key, 'line')
            end
        end
        self.camera:unset()
    end)

    ----
    function self.entities.update(s, dt)
        for i, e in pairs(s.entities) do
            if e.type_id ~= 'player' and e:is(Mob) then
                if (not self.doorsOpened) or e.dead then
                    e:update(dt)
                end
            else
                e:update(dt)
            end
        end
    end

end

function room:name()
    return 'room'..tostring(self.pos)
end

function room:closeDoors()
    self.doorsOpened = false
    for i, door in pairs(self.doors) do
        if type(door) == 'table' then
            for j, tile in pairs(door.old_tiles) do
                self.Timer:after(j/40, function ()
                    self.tiledmap:setTile(tile.layer, tile.pos.x, tile.pos.y, tile.id)
                end)
            end
        end
    end
end

function room:openDoors()
    self.doorsOpened = true
    for i, door in pairs(self.doors) do
        if type(door) == 'table' then
            for j, tile in pairs(door.old_tiles) do
                self.Timer:after(j/40, function ()
                    self.tiledmap:setTile(tile.layer, tile.pos.x, tile.pos.y, 0)
                end)
            end
        end
    end
end

function room:enter(ent, mvec)
    if ent == nil then return end
    assert(ent:is(entitySystem.entity), 'it is not an entity!')

    ent.__old_room.physics:remove(ent)
    while ent.__old_room.entities:hasEntity(ent) do
        ent.__old_room.entities:removeEntity(ent)
    end

    local oldmvec = mvec
    mvec = tostring(mvec):sub(2, #mvec-2):replace('-1', '2')
    --inverted
    mvec = mvec:replace('1, 0', 'left'):replace('2, 0', 'right'):replace('0, 1', 'down'):replace('0, 2', 'up')

    local nx, ny = self.doors[mvec].x + self.doors[mvec].width / 2 - ent.hitbox.sx /2,
                   self.doors[mvec].y + self.doors[mvec].height / 2 - ent.hitbox.sy /2

    local new = self.entities:createEntity(ent.type_id, self, vec2(nx, ny))
    while not self.entities:hasEntity(new) do
        new = self.entities:createEntity(ent.type_id, self, vec2(nx, ny))
    end
    local avoid = { 'room', 'physics', 'pos', 'vel', '__system', 'owner' }
    for i, c in pairs(ent) do
        local b = true
        for ii, a in pairs(avoid) do
            if i == a then b = false end
        end
        if b then new[i] = c end
    end

    _G.ROOM = self
    new:on_new_room(oldmvec.x, oldmvec.y)
end

function room:exit(ent)
    if ent == nil then return end
    assert(ent:is(entitySystem.entity), 'it is not an entity!')
    ent.__old_room = self
end

function room:checkCleared()
    for i, e in pairs(self.entities.entities) do
        if e:is(Mob) and e.type_id ~= 'player' and e.dead == false then
            return false
        end
    end
    return true
end

function room:update(dt)
    _G.CAMERA = self.camera

    self.tiledmap:update(dt)
    self.entities:update(dt)
    self.particles:update(dt)

    if (not self.cleared) and self:checkCleared() then
        self.cleared = true
    end

    if not self.doorsOpened then
        self.Time:update(dt)
    end
    self.Timer:update(dt)
end

function room:draw()
    love.graphics.setColor(self.tiledmap.backgroundcolor)
    love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)
    love.graphics.setColor(1,1,1,1)
    self.render:draw()
end

function room:mousepressed(x, y, but)
    self.entities:mousepressed(x, y, but)
end

function room:mousereleased(x, y, but)
    self.entities:mousereleased(x, y, but)
end

function room:keypressed(key)
    self.entities:keypressed(key)
end

function room:keyreleased(key)
    self.entities:keyreleased(key)
end

return room