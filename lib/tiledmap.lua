local tiledmap = class()

local function loadXmlFile(filename)
    assert(love.filesystem.getInfo(filename) ~= nil, 'file ' .. filename .. ' is not exists!')
    local file = love.filesystem.read(filename)
    local handler = love.filesystem.load("lib/xmlhandler/tree.lua")()
    local parser = xmlLoader.parser(handler)
    parser:parse(file)
    return handler.root
end

local function objectsTable(t, objname)
    local r = {}
    if t[objname]._attr then
        r[1] = t[objname]
    else
        for k, v in pairs(t[objname]) do
            table.insert(r, t[objname][k])
        end
    end
    return r
end

local function valueToType(type, value)
    if type == 'int' or type == 'float' then
        return tonumber(value)
    elseif type == 'bool' then
        return --aowdja[wdjwadjw[ad[wad[wjad]]]]
    end
    return value
end

local function getProperties(t)
    local properties = {}
    for i, prop in pairs(objectsTable(t.properties, 'property')) do
        properties[prop._attr.name] = valueToType(prop._attr.type, prop._attr.value) or prop[1]
    end
    return properties
end

local function clipTileSet(img, tsx, tsy)
    local quads = {}
    for y = 0, img:getHeight() / tsy - 1 do
        for x = 0, img:getWidth() / tsx - 1 do
            table.insert(quads, love.graphics.newQuad(
                x * tsx,
                y * tsy,
                tsx,
                tsy,
                img:getDimensions()
            ))
        end
    end
    return quads
end

local function hex2rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x"..hex:sub(1, 2)) / 255, tonumber("0x"..hex:sub(3, 4)) / 255, tonumber("0x"..hex:sub(5, 6)) / 255
end

function tiledmap:new(filename, room)
    local mapFile = loadXmlFile(filename).map
    
    self.width      = tonumber(mapFile._attr.width)
    self.height     = tonumber(mapFile._attr.height)
    self.tilewidth  = tonumber(mapFile._attr.tilewidth)
    self.tileheight = tonumber(mapFile._attr.tileheight)

    self.backgroundcolor = color( hex2rgb(mapFile._attr.backgroundcolor) )

    self.real_width  = self.width  * self.tilewidth
    self.real_height = self.height * self.tileheight

    self.properties = getProperties(mapFile)

    self.layers = {}
    for i, l in pairs(objectsTable(mapFile, 'layer')) do
        self.layers[i] = {
            name = l._attr.name,
            width  = tonumber(l._attr.width),
            height = tonumber(l._attr.height),
            properties = getProperties(l),
            data = load('return {' .. l.data[1] .. '}')(),
            pos = i
        }
    end

    self.objectgroups = {}
    for i, group in pairs(objectsTable(mapFile, 'objectgroup')) do
        self.objectgroups[i] = {
            name = group._attr.name,
            properties = getProperties(group)
        }
        self.objectgroups[i].objects = {}
        for j, obj in pairs(objectsTable(group, 'object')) do
            self.objectgroups[i].objects[j] = {
                id = obj._attr.id,
                x = tonumber(obj._attr.x),
                y = tonumber(obj._attr.y),
                width  = tonumber(obj._attr.width),
                height = tonumber(obj._attr.height),
                properties = getProperties(obj)
            }
        end
    end

    local tilesetFile = loadXmlFile( filename:match('.+/') .. objectsTable(mapFile, 'tileset')[1]._attr.source ).tileset
    self.tileset = {}

    local img = objectsTable(tilesetFile, 'image')[1]
    self.tileset.image = {
        source = love.graphics.newImage(img._attr.source:sub(7, #img._attr.source)),
        width  = tonumber(img._attr.width),
        height = tonumber(img._attr.height)
    }

    for i, l in pairs(self.layers) do
        l.batch = love.graphics.newSpriteBatch(self.tileset.image.source)
    end

    self.tileset.quads = clipTileSet(self.tileset.image.source, self.tilewidth, self.tileheight)

    self.tileset.tiles = {}
    for i, tile in pairs(objectsTable(tilesetFile, 'tile')) do
        self.tileset.tiles[tonumber(tile._attr.id)+1] = {
            id = tonumber(tile._attr.id)+1
        }

        if tile.objectgroup then
            self.tileset.tiles[tonumber(tile._attr.id)+1].objectgroup = {}
            for j, obj in pairs(objectsTable(tile.objectgroup, 'object')) do
                self.tileset.tiles[tonumber(tile._attr.id)+1].objectgroup[j] = {
                    x = tonumber(obj._attr.x),
                    y = tonumber(obj._attr.y),
                    width  = tonumber(obj._attr.width),
                    height = tonumber(obj._attr.height)
                }
            end
        end

        if tile.animation then
            self.tileset.tiles[tonumber(tile._attr.id)+1].animation = {
                frame = 1,
                time = 0
            }
            for j, frame in pairs(objectsTable(tile.animation, 'frame')) do
                self.tileset.tiles[tonumber(tile._attr.id)+1].animation[j] = {
                    tileid   = tonumber(frame._attr.tileid),
                    duration = tonumber(frame._attr.duration)
                }
            end
        end

    end

    if room then
        self.room = room
        for i, l in pairs(self.layers) do
            self:tile_physics_load(self.room.physics, l.name)
        end
        for i, g in pairs(self.objectgroups) do
            for j, obj in pairs(g.objects) do
                self:addObject(self.room, g.properties.type, obj)
            end
        end
    end

end

function tiledmap:update(dt)
    for i, tile in pairs(self.tileset.tiles) do
        if tile.animation then
            tile.animation.time = tile.animation.time + dt
            if tile.animation.time > tile.animation[ tile.animation.frame ].duration / 1000 then
                tile.animation.time = 0
                tile.animation.frame = tile.animation.frame + 1
                if tile.animation.frame > #tile.animation then
                    tile.animation.frame = 1
                end
            end
        end
    end
end

function tiledmap:drawTileLayer(n, ...)
    self.layers[n].batch:clear()
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local tile = self.layers[n].data[x+y*self.width+1]

            --animation
            if self.tileset.tiles[tile] and self.tileset.tiles[tile].animation then
                tile = self.tileset.tiles[tile].animation[ self.tileset.tiles[tile].animation.frame ].tileid
            end

            if tile ~= 0 then
                self.layers[n].batch:add(
                    self.tileset.quads[tile],
                    x*self.tilewidth,
                    y*self.tileheight
                )
            end
        end
    end
    love.graphics.draw(self.layers[n].batch, ...)
end

function tiledmap:getLayer(name)
    for i, l in pairs(self.layers) do
        if l.name == name or i == name then
            return l
        end
    end
    error("can't find layer " .. tostring(name))
end

function tiledmap:setTile(layer, x, y, id)
    assert(x >= 0 and x <= self.width and y >= 0 and y <= self.height, "can't find tile on (" .. tostring(x) .. ", " .. tostring(y) .. ")")
    x, y = x - 1, y - 1
    layer = self:getLayer(layer)
    local old = layer.data[x+y*self.width+1]
    layer.data[x+y*self.width+1] = id
    if self.room then
        self:tile_physics_unload(self.room)
        for i, l in pairs(self.layers) do
            self:tile_physics_load(self.room.physics, l.name)
        end
    end
    return old, id
end

function tiledmap:getTile(layer, x, y)
    assert(x >= 0 and x <= self.width and y >= 0 and y <= self.height, "can't find tile on (" .. tostring(x) .. ", " .. tostring(y) .. ")")
    layer = self:getLayer(layer)
    return layer.data[x+y*self.width+1]
end

function tiledmap:addObject(room, type, obj)
    if type == 'triggers' then
        assert(obj.properties.code, "trigger 'code' property is nil!")
        obj.__code = load(obj.properties.code)()
        obj.isTrigger = true
        room.physics:add(obj, 'rectangle', obj.x, obj.y, obj.width, obj.height)
    elseif type == 'scripts' then
        assert(obj.properties.code, "script 'code' property is nil!")
        load(obj.properties.code)()
        return
    elseif type == 'doors' then
        --in room
        return
    elseif type == 'entities' then
        assert(obj.properties.type_id, "'type_id' property is nil!")
        room.entities:createEntity(obj.properties.type_id, room, vec2(obj.x, obj.y))
        return
    else
        room.physics:add(obj, 'rectangle', obj.x, obj.y, obj.width, obj.height)
    end
end

function tiledmap:tile_physics_unload(room)
    for i, item in pairs(room.physics.items) do
        if item.key.isTile then
            room.physics:remove(item.key)
        end
    end
end

function tiledmap:tile_physics_load(physics, layer)
    layer = self:getLayer(layer)
    for id, tile in pairs(self.tileset.tiles) do
        for y = 0, self.height - 1 do
            for x = 0, self.width - 1 do
                if tile.id == layer.data[x+y*self.width+1] then
                    for ii, obj in pairs(tile.objectgroup or {}) do
                        if type(obj) == 'table' then
                            local t = {
                                pos       = { x = x*self.tilewidth, y = y*self.tileheight },
                                size      = { x = self.tilewidth,   y = self.tileheight },
                                layer     = layer.pos,
                                isTile    = true
                            }
                            physics:add(t, 'rectangle', obj.x+t.pos.x, obj.y+t.pos.y, obj.width, obj.height)
                        end
                    end
                end
            end
        end
    end
end

return tiledmap

--[[local tiledmap = class()

function tiledmap:new(room, filename)

    --access to room
    self.room = room

    --load map and tileset from tmx files
    self.source = filename
    self.mapFile = self:loadXmlFile(filename).map

    local path, ipos = filename, #filename
    while path:sub(ipos, ipos) ~= '/' and ipos > 0 do
        ipos = ipos - 1
    end
    path = path:sub(1, ipos)

    self.tileSetFile = self:loadXmlFile(path..self.mapFile.tileset.source).tileset

    --generate quads
    self.tileSetFile.source = love.graphics.newImage( string.replace(self.tileSetFile.image.source, '../', '') )
    self.tileSetFile.quads = self:generate_quads(
        self.tileSetFile.source,
        tonumber(self.mapFile.tilewidth),
        tonumber(self.tileSetFile.spacing)
    )

    --backgroundcolor
    if self.mapFile.backgroundcolor then
        self.mapFile.backgroundcolor = color( hex2rgb(self.mapFile.backgroundcolor) )
    else
        self.mapFile.backgroundcolor = color(0, 0, 0)
    end

    --physics
    self.physics = self.room.physics

    --load tile layers physics
    for i, l in pairs(self.mapFile.layer) do
        --normalize layers tile data
        self.mapFile.layer[i].data[1] = load("return{" .. self.mapFile.layer[i].data[1] .. "}")()
        --load
        self:tile_physics_load(i)
    end

    --load objectgroup
    for i, g in pairs(self.mapFile.objectgroup) do
        --get objectgroup type property
        local type = nil
        if not g.properties.property[1] then
            if g.properties.property.name == 'type' then type = g.properties.property.value end
        else
            for j, p in pairs(g.properties.property) do
                if p.name == 'type' then type = p.value end
            end
        end
        --add object
        type = type:replace('triggers', 'trigger'):replace('doors', 'door'):replace('entities', 'entity'):replace('scripts', 'script')
        if not g.object[1] then
            self:addObject(type, g.object)
        else
            for j, obj in pairs(g.object) do
                self:addObject(type, obj)
            end
        end
    end

    --animated tiles
    self.animatedTiles = {}
    for i, tile in pairs(self.tileSetFile.tile) do
        if tile.animation then
            local id = tonumber(tile.id)+1
            self.animatedTiles[id] = {
                frame = 1
            }
            for j, frame in pairs(tile.animation.frame) do
                table.insert(self.animatedTiles[id], {
                    id       = tonumber(frame.tileid)+1,
                    duration = tonumber(frame.duration),
                    time     = 0
                })
            end
        end
    end

    --redering
    self.layerBatches = {}
    for i, l in pairs(self.mapFile.layer) do
        self.layerBatches[i] = love.graphics.newSpriteBatch(self.tileSetFile.source, self.mapFile.width*self.mapFile.height)
    end
    
end

function tiledmap:update(dt)
    for i, anim in pairs(self.animatedTiles) do
        anim[anim.frame].time = anim[anim.frame].time + dt
        if anim[anim.frame].time > anim[anim.frame].duration / 1000 then
            anim[anim.frame].time = 0
            anim.frame = anim.frame + 1
            if anim.frame > #anim then
                anim.frame = 1
            end
        end
    end
end

function tiledmap:loadXmlFile(filename)
    local info = love.filesystem.getInfo(filename)
    assert(info ~= nil, 'file ' .. filename .. ' is not exists!')
    local file = love.filesystem.read(filename)
    local handler = love.filesystem.load("lib/xmlhandler/tree.lua")()
    local parser = xmlLoader.parser(handler)
    parser:parse( file )
    local function AttrRemove(t)
        for i, c in pairs(t) do
            if i == '_attr' then
                for i, c in pairs(t['_attr']) do
                    if tonumber(c) ~= nil then t[i] = tonumber(c) else t[i] = c end
                end
                t['_attr'] = nil
            elseif type(c) == 'table' then
                t[i] = AttrRemove(t[i])
            end
        end
        return t
    end
    return AttrRemove(handler.root)
end

--for tile set
function tiledmap:generate_quads(img, size, ofset)
    assert(img  ~= nil)
    assert(size ~= nil)
    ofset = ofset or 0
    local quads = {}
    local sx = math.floor(img:getWidth()  / size)
    local sy = math.floor(img:getHeight() / size)
    for y = 0, sy - 1 do
        for x = 0, sx - 1 do
            table.insert(quads, 
                love.graphics.newQuad(x*size+ofset*x, y*size+ofset*y, size, size, img:getDimensions())
            )
        end
    end
    return quads
end

function tiledmap:addObject(type, obj)
    local props = obj.properties.property
    local value = obj.properties.property[1] or obj.properties.property.value
    if type == 'trigger' then
        assert(props.name == 'code', "trigger 'code' property is nil!")
        obj.__code    = load(value)()
        obj.isTrigger = true
    elseif type == 'script' then
        assert(props.name == 'code', "trigger 'code' property is nil!")
        load(value)(obj)
        return
    elseif type == 'entity' then
        assert(props.name == 'type_id', "'type_id' property is nil!")
        self.room.entities:createEntity(props.value, self.room, vec2(obj.x, obj.y))
        return 
    elseif type == 'door' then
        --works in room
        return
    end
    self.physics:add(obj, 'rectangle', obj.x, obj.y, obj.width, obj.height)
end

function tiledmap:tile_physics_unload()
    for i, item in pairs(self.physics.items) do
        if item.key.isTile then
            self.physics:remove(item.key)
        end
    end
end

function tiledmap:tile_physics_load(layer)
    if type(layer) == 'number' then
        local layer_n = layer
        layer = self.mapFile.layer[layer]
    end
    for id, tile in pairs(self.tileSetFile.tile) do
        for y = 0, self.mapFile.height - 1 do
            for x = 0, self.mapFile.width - 1 do
                if tile.id == layer.data[1][x+y*self.mapFile.width+1]-1 then
                    for ii, obj in pairs(tile.objectgroup or {}) do
                        if type(obj) == 'table' then
                            local t = {
                                pos       = { x = x*self.mapFile.tilewidth, y = y*self.mapFile.tileheight },
                                size      = { x = self.mapFile.tilewidth,   y = self.mapFile.tileheight },
                                layer     = layer_n,
                                isTile    = true
                            }
                            self.physics:add(t, 'rectangle', obj.x+t.pos.x, obj.y+t.pos.y, obj.width, obj.height)
                        end
                    end
                end
            end
        end
    end
end

function tiledmap:updateTile(x, y, l, id)
    assert(x > 0 and y > 0 and x < self.mapFile.width+1 and y < self.mapFile.height+1, 'tile ' .. tostring( vec2(x,y) ) .. ' in ' .. self.room.name .. ' is nil!')
    assert(l > 0 and l < #self.mapFile.layer+1, 'layer ' .. l .. ' in ' .. self.room.name .. ' is nil!')
    x, y = x - 1, y - 1

    local oldid = self.mapFile.layer[l].data[1][x+y*self.mapFile.width+1]
    self.mapFile.layer[l].data[1][x+y*self.mapFile.width+1] = id
    
    self:tile_physics_unload()
    for i, ll in pairs(self.mapFile.layer) do
        self:tile_physics_load(i)
    end

    return oldid, id
end

function tiledmap:drawTileLayer(n)
    local layer = self.mapFile.layer[n]
    assert(layer, 'layer to draw is nil!')
    self.layerBatches[n]:clear()
    for y = 0, self.mapFile.height - 1 do
        for x = 0, self.mapFile.width - 1 do
            local tile = layer.data[1][x+y*layer.width+1]

            --animation
            if self.animatedTiles[tile] then
                tile = self.animatedTiles[tile][self.animatedTiles[tile].frame].id
            end

            if tile ~= 0 then
                self.layerBatches[n]:add(
                    self.tileSetFile.quads[tile],
                    x*self.mapFile.tilewidth,
                    y*self.mapFile.tileheight
                )
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.layerBatches[n], 0, 0)
end

return tiledmap]]