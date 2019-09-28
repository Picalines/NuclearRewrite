local label = class(UI.element)

function label:new(pos, size)
    self.pos  = vec2(pos.x, pos.y)
    self.size = vec2(size.x, size.y)

    self.style = {
        font        = love.graphics.newFont(Assets.fonts.Arial, 24),
        text        = 'nill',
        textcolor   = color(1, 1, 1, 1),
        backcolor   = color(0, 0, 0, 0),
        strokewidth = 0,
        strokecolor = color(1, 1, 1, 1)
    }

end

function label:draw()
    if self.style.strokewidth > 0 and self.style.strokecolor.a > 0 then
        love.graphics.setColor(self.style.strokecolor)
        love.graphics.rectangle('fill',
            self.pos.x-self.size.x/2-self.style.strokewidth,
            self.pos.y-self.size.y/2-self.style.strokewidth,
            self.size.x+self.style.strokewidth*2,
            self.size.y+self.style.strokewidth*2
        )
    end
    if self.style.backcolor.a > 0 then
        love.graphics.setColor(self.style.backcolor)
        love.graphics.rectangle('fill', self.pos.x-self.size.x/2, self.pos.y-self.size.y/2, self.size.x, self.size.y)
    end
    if self.style.textcolor.a > 0 then
        love.graphics.setColor(self.style.textcolor)
        love.graphics.setFont(self.style.font)
        local tsx, tsy = self.style.font:getWidth(self.style.text), self.style.font:getHeight(self.style.text)
        love.graphics.print(self.style.text, self.pos.x-tsx/2, self.pos.y-tsy/2)
    end
end

return label