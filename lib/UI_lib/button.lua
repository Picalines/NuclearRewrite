local button = class(UI.element)

button.name = 'button'

function button:new(pos, size)
    self.pressed = false

    self.style = {
        color     = color(0, 0, 0),
        capcolor  = color(1, 1, 1),
        caption   = button.name,
        sprite    = love.image.newImageData(100, 100),
        font      = love.graphics.newFont(Assets.fonts.Arial, 24)
    }
    
    self.callbacks = {
        mouseDown = function () end,
        mouseUp   = function () end,
        mouseHold = function () end
    }

    self.pos  = vec2(pos.x, pos.y)
    self.size = vec2(size.x, size.y)
end

function button:setCallback(calls)
    for k, v in pairs(calls) do
        assert(self.callbacks[k], k .. ' callback is not exists!')
        assert(type(self.callbacks[k]) == 'function', 'callback type must be a function!')
        self.callbacks[k] = v
    end
    return self
end

function button:update(dt)
    if self.pressed then
        self.callbacks.mouseHold(self)
    end
end

function button:draw()
    --color
    love.graphics.setColor(self.style.color)
    love.graphics.rectangle('line', self.pos.x-self.size.x/2, self.pos.y-self.size.y/2, self.size.x, self.size.y)
    --sprite
    if self.style.sprite:typeOf('Image') then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.style.sprite, self.pos.x-self.size.x/2, self.pos.y-self.size.y/2)
    end
    --caption
    if self.style.caption ~= "" then
        love.graphics.setFont(self.style.font)
        love.graphics.setColor(self.style.capcolor)
        local csx, csy = self.style.font:getWidth(self.style.caption), self.style.font:getHeight(self.style.caption)
        love.graphics.print(self.style.caption, self.pos.x-csx/2, self.pos.y-csy/2)
    end
end

function button:mousepressed(x, y, but)
    if but == 1 and ((x >= self.pos.x-self.size.x/2) and (x <= self.pos.x+self.size.x/2) and
        (y >= self.pos.y-self.size.y/2) and (y <= self.pos.y+self.size.y/2)) and not self.pressed then
        self.pressed = true
        self.callbacks.mouseDown(self)
    end
end

function button:mousereleased(x, y, but)
    if but == 1 and self.pressed then
        self.pressed = false
        self.callbacks.mouseUp(self)
    end
end

return button