local bar = class(UI.element)

bar.name = 'bar'

function bar:new(pos, size, min, max, init)
    self.style = {
        dir         = 'right',
        color       = color(1, 1, 1),
        backcolor   = color(0.5, 0.5, 0.5),
        strokewidth = 0,
        strokecolor = color(0.7, 0.7, 0.7),
        caption     = "%d/%d",
        capcolor    = color(0, 0, 0),
        font        = love.graphics.newFont(Assets.fonts.Arial, 24),
        autoclamp   = true
    }

    self.pos  = vec2(pos.x, pos.y)
    self.size = vec2(size.x, size.y)

    self.min   = min or 0
    self.max   = max or 0
    self.value = init or self.max

end

function bar:update(dt)
    if self.style.autoclamp then
        self.value = math.clamp(self.min, self.value, self.max)
    end
end

function bar:draw()
    if self.style.strokewidth > 0 then
        love.graphics.setColor(self.style.strokecolor)
        love.graphics.rectangle('fill',
            self.pos.x-self.size.x/2-self.style.strokewidth,
            self.pos.y-self.size.y/2-self.style.strokewidth,
            self.size.x+self.style.strokewidth*2,
            self.size.y+self.style.strokewidth*2
        )
    end
    love.graphics.setColor(self.style.backcolor)
    love.graphics.rectangle('fill', self.pos.x-self.size.x/2, self.pos.y-self.size.y/2, self.size.x, self.size.y)
    love.graphics.setColor(self.style.color)
    local w = 0
    if self.style.dir == 'right' then
        w = (self.value/self.max)*self.size.x
        love.graphics.rectangle('fill', self.pos.x-self.size.x/2, self.pos.y-self.size.y/2, w, self.size.y)
    elseif self.style.dir == 'left' then
        w = (self.value/self.max)*self.size.x
        love.graphics.rectangle('fill', self.pos.x+self.size.x/2, self.pos.y-self.size.y/2, -w, self.size.y)
    end

    love.graphics.setColor(self.style.capcolor)
    love.graphics.setFont(self.style.font)
    local fc = string.format(self.style.caption, self.value, self.max)
    local csx, csy = self.style.font:getWidth(fc), self.style.font:getHeight(fc)
    love.graphics.print(fc, self.pos.x-csx/2, self.pos.y-csy/2)
end

return bar