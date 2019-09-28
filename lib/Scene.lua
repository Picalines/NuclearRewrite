local scene = class()

function scene:new(name)
    self.name   = name or 'SCENE_NAME'
    self.called = true
end

function scene:load()   end
function scene:enter()  end
function scene:exit()   end

function scene:draw()   end
function scene:update() end

function scene:mousepressed()  end
function scene:mousereleased() end

function scene:keypressed()  end
function scene:keyreleased() end

function scene:__tostring()
    return self.name
end

return scene