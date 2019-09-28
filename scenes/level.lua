local Level = class()

function Level:new(name, folder, rooms_count)
    --params
    self.rooms_count = rooms_count
    self.name        = name
    self.folder      = folder
    --Rooms
    self.rooms = SceneManager()

    function self.rooms:move(dx, dy, ent)
        local name = load('return vec2'..self.CurrentScene:gsub('room', ''))()
        local nameX, nameY = name.x, name.y
        local gameScene = SCENES:get('GameScreen')
        if not ent:on_room_move(dx, dy) then
            return
        end
        if ent.type_id == 'player' then
            gameScene.PLAYING = false

            local time = 0.5
            local bclr = color( ROOM.tiledmap.backgroundcolor:get() ) 

            Player.anim:setType('walk')
            gameScene.Timer:during(time/2, function ()
                Player.pos.x = Player.pos.x + dx * 3
                Player.pos.y = Player.pos.y - dy * 3
                Player.anim:update(DeltaTime*1.1)
                Player:weaponsUpdate(DeltaTime)
            end)

            gameScene.Timer:after( time/4, function ()
                gameScene.Timer:tween(time/4, gameScene.curtain, { a = 1, r = bclr.r, g = bclr.g, b = bclr.b }, 'linear', function ()
                    _G.ROOM = self:switch('room'..tostring(vec2(nameX + dx, nameY + dy)), {ent, vec2(dx, dy)}, {ent})
                    ROOM.visited = true

                    for i, v in pairs{vec2(-1, 0), vec2(1, 0), vec2(0, -1), vec2(0, 1)} do
                        if ROOMS.scenes['room' .. tostring(ROOM.pos+v)] then
                            ROOMS.scenes['room' .. tostring(ROOM.pos+v)].reached = true
                        end
                    end

                    _G.CAMERA = ROOM.camera
                    _G.Player = ROOM.entities:getEntity('player')
                    CAMERA.pos = vec2(Player.pos.x+Player.hitbox.sx/2, Player.pos.y+Player.hitbox.sy/2)

                    Player.pos = Player.pos + vec2(-dx, dy) * 3 * time/2 * 60
                    gameScene.Timer:during(time/2,
                    function ()
                        Player.pos.x = Player.pos.x + dx * 3
                        Player.pos.y = Player.pos.y - dy * 3
                        Player.anim:update(DeltaTime*1.1)
                        Player:weaponsUpdate(DeltaTime)
                    end,
                    function ()
                        Player.anim:setType('stand')
                    end)

                    ROOM.Timer:tween(time/2, _G.CAMERA, { zoom = ent.__old_room.camera.zoom }, 'in-out-back')
                    gameScene.Timer:tween(time/2, gameScene.curtain, {a = 0}, 'linear', function ()
                        gameScene.PLAYING = true
                    end)
                end)
            end)

            return
        end
        self:get('room' .. tostring(vec2(nameX, nameY))):exit(ent)
        self:get('room' .. tostring(vec2(nameX+dx, nameY+dy))):enter(ent, vec2(dx, dy))
    end

    self.generated = false
    self.generateStatus = 'init'
end

local gen_pos, center, poses, doors, maps, types, map, currentPos, mapChoose

local function nameGen(pos)
    return "room" .. tostring(pos)
end

local function getRoomTypeFromFilename(filename)
    local typ, slpos, bmpos = filename, filename:len(), 1
    while typ:sub(slpos, slpos) ~= '/' and slpos >= 1 do
        slpos = slpos - 1
    end
    while typ:sub(bmpos, bmpos) ~= '_' and bmpos <= typ:len() do
        bmpos = bmpos + 1
    end
    return typ:sub(slpos+1, bmpos-1)
end

local function addRoomPos()
    while table.find(poses, vec2(gen_pos.x, gen_pos.y)) do
        local dir = {[0] = -1, [1] = 1}
        dir = dir[math.random(0, 1)]
        if math.random(0, 1) == 0 then
            gen_pos.x = gen_pos.x + dir
        else
            gen_pos.y = gen_pos.y + dir
        end
    end
    table.insert(poses, vec2(gen_pos.x, gen_pos.y))
end

function Level:generate()
    self.generated = false
    if self.generateStatus == 'init' then
        colorPrint({"---" .. self.name .. " level generation started!---"}, color(1, 1, 0))

        self.rooms.scenes = {}
        self.rooms.CurrentScene = nil
        self.rooms.PrevScene    = nil

        gen_pos = vec2(1, 1)
        center = vec2(gen_pos.x, gen_pos.y)

        poses = {}
        doors = {}
        types = {}

        map = self.folder.."/s_start.tmx"
        maps = {}
        for i, m in pairs(love.filesystem.getDirectoryItems(self.folder)) do
            if string.find(m, 'tmx') then
                table.insert(maps, self.folder.."/"..m)
            end
        end

        currentPos = 1
        function mapChoose()
            local old = map
            while map == old or map == self.folder.."/s_start.tmx" do
                map = table.random(maps)
            end
            --print(getRoomTypeFromFilename(map), types[currentPos])
            if getRoomTypeFromFilename(map) ~= types[currentPos] then
                mapChoose()
            end
        end

        colorPrint({'---Initialization complete---'}, color(0.5, 1, 0.5))
        self.generateStatus = 'poses'
    elseif self.generateStatus == 'poses' then

        if #poses < self.rooms_count then
            addRoomPos()
        else
            colorPrint({'---Final poses:---'}, color(0.5, 1, 0.5))
            print(unpack(poses))
            self.generateStatus = 'doors'
        end

    elseif self.generateStatus == 'doors' then

        local door = {
            right = false,
            left  = false,
            up    = false,
            down  = false
        }
        if table.find(poses, poses[currentPos] + vec2(1, 0))  then door.right = true end
        if table.find(poses, poses[currentPos] + vec2(-1, 0)) then door.left  = true end
        if table.find(poses, poses[currentPos] + vec2(0, 1))  then door.up    = true end
        if table.find(poses, poses[currentPos] + vec2(0, -1)) then door.down  = true end

        doors[currentPos] = door

        currentPos = currentPos + 1

        if not poses[currentPos] then 
            currentPos = 1
            colorPrint({'---Doors generated---'}, color(0.5, 1, 0.5))
            colorPrint({'---Room types placing started---'}, color(1, 1, 0))
            self.generateStatus = 'types'
        end

    elseif self.generateStatus == 'types' then

        if not poses[currentPos] then
            currentPos = 1
            self.generateStatus = 'rooms'
            colorPrint({'---Room types placed---'}, color(1, 1, 0))
            colorPrint({'---Rooms placing started---'}, color(1, 1, 0))
            return false
        end

        if currentPos == 1 then
            types[currentPos] = 's' --'start_room'
        elseif currentPos == math.floor(#poses/2) then
            types[currentPos] = 't' --'treasure_room'
        elseif currentPos == #poses then
            types[currentPos] = 'b' --'boss_room'
        else
            types[currentPos] = 'm' --'monster_room'
        end

        currentPos = currentPos + 1

    elseif self.generateStatus == 'rooms' then

        if not poses[currentPos] then
            self.generateStatus = 'end'
            return false
        end

        if poses[currentPos] ~= center then
            mapChoose()
        end

        local ok, msg = pcall(function ()
            local r = Room
            r.name = nameGen(poses[currentPos])
            self.rooms:add( r, poses[currentPos], map, doors[currentPos] )
        end)

        if not ok then
            if msg:find('Not enough doors') and DEBUG.generationNED then
                colorPrint({'  ' .. msg .. ' <- ' .. map}, color(1, 0.5, 0.5))
            elseif not msg:find('Not enough doors') then
                colorPrint({'  ' .. msg .. ' <- ' .. map}, color(1, 0.5, 0.5))
            end
            mapChoose()
            --colorPrint({'    try:'..map}, color(0.9, 0.5, 0.5))
        else
            currentPos = currentPos + 1
        end

    elseif self.generateStatus == 'end' then

        self:enter()

        colorPrint({"---Final rooms:---"}, color(0, 1, 0))
        if #self.rooms:listOfScenes() <= 6 then
            colorPrint(self.rooms:listOfScenes(), color(0.5, 1, 0.5))
        else
            local list = self.rooms:listOfScenes()
            for i = 1, #list, 3 do
                colorPrint({list[i], list[i+1], list[i+2]}, color(0.5, 1, 0.5))
            end
            colorPrint({'count: '..#list}, color(0.5, 1, 0.5))
        end

        self.generateStatus = 'init'
        self.generated = true
        return true

    end

    return false
end

function Level:globalsLoad()
    _G.ROOMS = self.rooms
    _G.START_ROOM = self.rooms:get('room'..tostring(center))
    _G.ROOM = _G.START_ROOM

    ROOM.visited = true
    for i, v in pairs{vec2(-1, 0), vec2(1, 0), vec2(0, -1), vec2(0, 1)} do
        if ROOMS.scenes['room' .. tostring(ROOM.pos+v)] then
            ROOMS.scenes['room' .. tostring(ROOM.pos+v)].reached = true
        end
    end

    _G.Player = _G.ROOM.entities.entities[1]
    self.rooms:switch(_G.START_ROOM.name)
end

function Level:enter()
    local mmap = SCENES:get("GameScreen").minimap
    mmap.dx, mmap.dy = 0, 0
    self:globalsLoad()
    TIME:tween(1, self.rooms:get(_G.START_ROOM.name), {camera = {zoom = 3.5}}, 'out-cubic')
end

function Level:draw()
    self.rooms:draw()
end

function Level:update(dt)
    self.rooms:update(dt)
end

function Level:keypressed(key)
    self.rooms:keypressed(key)
end

function Level:mousepressed(x, y, but)
    self.rooms:mousepressed(x, y, but)
end

function Level:mousereleased(x, y, but)
    self.rooms:mousereleased(x, y, but)
end

return Level