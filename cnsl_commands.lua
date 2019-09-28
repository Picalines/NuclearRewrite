local comands = {}

comands['help'] = function (self)
    self:print('press escape to close console', color(0, 1, 0))
    self:print('~ to open console', color(0, 1, 0))
    self:print('list of commands:', color(0, 1, 0))
    for k, v in pairs(self.commands) do
        self:print('-  ' .. k, color(0, 1, 0))
    end
end

comands['close'] = function (self)
    love.event.quit()
end

comands['clear'] = function (self)
    self.history      = {}
    self.CurrentInput = 1
    self.inputs       = {}
end

comands['show FPS'] = function (self)
    DEBUG.showFPS = not DEBUG.showFPS
end

comands['show hitboxes'] = function (self)
    DEBUG.showHitBoxes = not DEBUG.showHitBoxes
end

comands['summon'] = function (self)
    if SCENES.CurrentScene ~= 'GameScreen' then
        self:print("can't summon entity on " .. tostring(SCENES.CurrentScene) .. " scene!" , color(1, 0, 0))
        return
    end
    if not self.fast_command then
        self:print('// print entity filename', color(1, 0, 1))
    end
    self.command_arguments_input = true
    function self:command_input(input)
        if EntityClasses[input] then
            local e = ROOM.entities:createEntity(input:gsub('.lua', ''), ROOM, Player.pos:clone())
            if e:is(Mob) then
                comands['ROOM to m'](CONSOLE)
            end
        else
            self:print("// can't find EntityClasses[" .. input .. '] class', color(1, 0, 0))
        end
        self.history[1].clr = color(1, 0, 1)
        return true
    end
end

comands['go to'] = function (self)
    if SCENES.CurrentScene ~= 'GameScreen' then
        self:print("can't go to other level on " .. tostring(SCENES.CurrentScene) .. " scene!" , color(1, 0, 0))
        return
    end
    if not self.fast_command then
        self:print('// print level name', color(1, 0, 1))
    end
    self.command_arguments_input = true
    function self:command_input(input)
        if not LEVELS.scenes[input] then
            if ROOMS.scenes[input] then
                self.history[1].clr = color(1, 0, 1)
                ROOMS:switch(input)
                return true
            end
            self:print("// can't find level " .. input, color(1, 0, 0))
        else
            self.history[1].clr = color(1, 0, 1)
            LEVELS:switch(input)
        end
        return true
    end
end

comands['clear room'] = function (self)
    if SCENES.CurrentScene ~= 'GameScreen' then
        self:print("can't summon entity on " .. tostring(SCENES.CurrentScene) .. " scene!" , color(1, 0, 0))
        return
    end
    for i, m in pairs(ROOM.entities.entities) do
        if m:is(Mob) and m.type_id ~= 'player' then
            m:updateHp(-m.hp.count)
        end
    end
end

--comands['assets reload'] = function (self)
--    self:print('Warning! Tilesets in rooms will not be reloaded!', color(1, 1, 0))
--    love.filesystem.load("assets/load.lua")()
--end

--comands['game reload'] = function (self)
--    love.filesystem.load("main.lua")()
--end

--comands['noclip'] = function (self)
--    if SCENES.CurrentScene ~= 'GameScreen' then
--        self:print("can't summon entity on " .. tostring(SCENES.CurrentScene) .. " scene!" , color(1, 0, 0))
--        return
--    end
--    if Player then
--        Player:unload_physics()
--    else
--        self:print("can't find Player (?)" , color(1, 0, 0))
--    end
--end

comands['ROOM to m'] = function (self)
    if SCENES.CurrentScene ~= 'GameScreen' then
        self:print("can't run command on " .. tostring(SCENES.CurrentScene) .. " scene!" , color(1, 0, 0))
        return
    end
    ROOM.cleared = false
    ROOM:closeDoors()
end

comands['entities list'] = function (self)
    for k, v in pairs(EntityClasses) do
        self:print("-  " .. k, color(0, 1, 1))
    end
end

comands['assets list'] = function (self, t, o)
    t, o = t or Assets, o or 0
    for k, v in pairs(t) do
        local s = ""
        for i = 1, o do s = s .. " " end
        if type(v) == 'table' and not v.volume then
            self:print(s .. "  -  " .. k, color(1, 1, 0))
            comands['assets list'](CONSOLE, v, o + 2)
        else
            self:print(s .. "  -  " .. k, color(0, 1, 1))
        end
    end
end

return comands
