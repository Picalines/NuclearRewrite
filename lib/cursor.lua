local cursor = class()

function cursor:new()
    self.x = 0
    self.y = 0
    self.image = Assets.GUIs.cursor_standart
    self.sx, self.sy = self.image:getDimensions()
    self.color = color(1, 1, 1, 1)
    self.visible = true
end

function cursor:draw()
    if self.visible then
        love.graphics.setColor(self.color)
        love.graphics.draw(self.image, self.x-self.sx/2, self.y-self.sy/2)
    end
end

function cursor:update(dt)
    self.x, self.y = CScreen.project( love.mouse.getPosition() )
end

return cursor