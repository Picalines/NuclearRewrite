local SceneManager = class()

function SceneManager:new(...)
    self.scenes = {}
    self.scenes_list = {}
    for i, scene in pairs{...} do
        self:add(scene)
    end
    self.CurrentScene = nil
    self.PrevScene    = nil
end

function SceneManager:add(scene, ...)
    assert(type(scene) == "table", "Scene type must be a table! (found " .. type(scene) .. ")")
    if not scene.called then scene = scene(scene.name) end
    assert(scene:is(Scene), "It is not a scene!")
    if type(scene.name) == 'function' then scene.name = scene.name(scene) end
    assert(self.scenes[scene.name] == nil, "Scene '"..scene.name.."' is already exists!")
    scene.manager = self
    scene:load(...)
    self.scenes[scene.name] = scene
    table.insert(self.scenes_list, tostring(scene.name))
    return scene
end

function SceneManager:remove(scene)
    assert(scene, "Scene argument in remove function is nil!")
    if type(scene) == "string" then
        assert(self.scenes[scene], "Scene '"..scene.."' is not found or nil!")
        scene = self.scenes[scene]
    end
    assert(scene:is(Scene), "It is not a scene!")
    for i, n in pairs(self.scenes_list) do
        if scene.name == n then
            table.remove(self.scenes_list, i)
        end
    end
    for i, sc in pairs(self.scenes) do
        if scene == self.scenes[i] then
            self.scenes[i] = nil
            break
        end
    end
end

function SceneManager:switch(scene, arg_enter, arg_exit)
    arg_enter = arg_enter or {}
    arg_exit  = arg_exit  or {}
    assert(type(scene) == "string", "Scenes name type in get function must be a string!")
    assert(self.scenes[scene], "Scene '"..scene.."' is not found or nil!")
    if self.CurrentScene then self.scenes[self.CurrentScene]:exit(unpack(arg_exit)) end
    self.PrevScene    = string.rep(self.CurrentScene or "nil", 1)
    self.CurrentScene = scene
    self.scenes[self.CurrentScene]:enter(unpack(arg_enter))
    return self.scenes[self.CurrentScene]
end

function SceneManager:clear()
    for i, name in pairs(self.scenes_list) do
        self:remove(name)
    end
    self.scenes = {}
end

function SceneManager:get(name)
    --assert(name, "Scenes name in get function is nil!")
    --assert(type(name) == "string", "Scenes name type in get function must be a string!")
    --assert(self.scenes[name], "Scene '"..name.."' is not found or nil!")
    return self.scenes[name]
end

function SceneManager:hasScene(name)
    --assert(name, "Scenes name in get function is nil!")
    --assert(type(name) == "string", "Scenes name type in hasScene function must be a string!")
    if self.scenes[name] ~= nil then
        return true
    end
    return false
end

function SceneManager:listOfScenes()
    --local sc = {}
    --for i, scene in pairs(self.scenes) do
    --    table.insert(sc, scene.name)
    --end
    return self.scenes_list
end

function SceneManager:draw()
    if self.scenes[self.CurrentScene] then 
        self.scenes[self.CurrentScene]:draw()
        love.graphics.setColor(255, 255, 255, 255)
    end
end

function SceneManager:update(dt)
    if self.scenes[self.CurrentScene] then
        self.scenes[self.CurrentScene]:update(dt)
    end
end

function SceneManager:mousepressed(x, y, but)
    if self.scenes[self.CurrentScene] then
        self.scenes[self.CurrentScene]:mousepressed(x, y, but)
    end
end

function SceneManager:mousereleased(x, y, but)
    if self.scenes[self.CurrentScene] then
        self.scenes[self.CurrentScene]:mousereleased(x, y, but)
    end
end

function SceneManager:keypressed(key)
    if self.scenes[self.CurrentScene] then
        self.scenes[self.CurrentScene]:keypressed(key)
    end
end

function SceneManager:keyreleased(key)
    if self.scenes[self.CurrentScene] then
        self.scenes[self.CurrentScene]:keyreleased(key)
    end
end

return SceneManager