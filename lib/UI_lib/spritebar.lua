local spriteBar = class(UI.element)
spriteBar.name = 'spriteBar'

function spriteBar:new(pos, sprite, initcount)
    self.pos    = pos
    self.sprite = sprite
    self.batch  = love.graphics.newSpriteBatch(self.sprite)
    self.count  = initcount or 0
    self.max    = self.count

    self.style = {
        ofset = 0,
        dir   = 'right',
        scale = 1,
        backcolor = color(0, 0, 0, 1),
        tintcolor = color(1, 1, 1, 1)
    }

end

function spriteBar:update(dt)
    self.value = math.clamp(0, self.count, self.count)
end

function spriteBar:draw()
    self.batch:clear()
    self.batch:setColor(self.style.backcolor)
    if self.style.dir == 'right' then
        for i = self.max - 1, 0, -1 do
            if i + 1 <= self.count then self.batch:setColor(self.style.tintcolor) end
            self.batch:add((self.sprite:getWidth() + self.style.ofset) * i * self.style.scale, 0, 0, self.style.scale, self.style.scale)
        end
    elseif self.style.dir == 'left' then
        for i = self.max - 1, 0, -1 do
            if i + 1 <= self.count then self.batch:setColor(self.style.tintcolor) end
            self.batch:add((self.sprite:getWidth() + self.style.ofset) * i * self.style.scale, 0, 0, self.style.scale, self.style.scale)
        end
    elseif self.style.dir == 'up' then
        for i = self.max - 1, 0, -1 do
            if i + 1 <= self.count then self.batch:setColor(self.style.tintcolor) end
            self.batch:add(0, -(self.sprite:getHeight() + self.style.ofset) * i * self.style.scale, 0, self.style.scale, self.style.scale)
        end
    elseif self.style.dir == 'down' then
        for i = self.max - 1, 0, -1 do
            if i + 1 <= self.count then self.batch:setColor(self.style.tintcolor) end
            self.batch:add(0, (self.sprite:getHeight() + self.style.ofset) * i * self.style.scale, 0, self.style.scale, self.style.scale)
        end
    end
    love.graphics.draw(self.batch, self.pos.x, self.pos.y)
end

return spriteBar