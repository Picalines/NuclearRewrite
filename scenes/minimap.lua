local minimap = class()

function minimap:new(x, y, sx, sy)
    self.dx, self.dy = 0
    self.x, self.y, self.sx, self.sy = x or 0, y or 0, sx or 100, sy or 100
    self.style = {
        room_size  = 16,
        room_ofset = 2,
        level_name = false,
        fixed      = false,
        background = color(0, 0, 0, 0)
    }
    return self
end

local function collideWithRoom(pos, cur)
    return ((pos.x == (cur.x - 1)) and (pos.y == cur.y)) or ((pos.x == (cur.x + 1)) and (pos.y == cur.y)) or
            ((pos.y == (cur.y - 1)) and (pos.x == cur.x)) or ((pos.y == (cur.y + 1)) and (pos.x == cur.x))
end

function minimap:draw(a)
    local x, y, sx, sy = self.x, self.y, self.sx, self.sy
    a = a or 1
    if a < 0.2 then
        return
    end
    
    love.graphics.setColor(self.style.background.r, self.style.background.g, self.style.background.b, self.style.background.a * a)
    love.graphics.rectangle('fill', x-sx/2, y-sy/2, sx, sy)
    love.graphics.stencil(function ()
        love.graphics.rectangle('fill', x-sx/2, y-sy/2, sx, sy)
    end)

    love.graphics.push()
    if self.style.fixed then
        love.graphics.translate(-(ROOM.pos.x-1) * self.style.room_size, (ROOM.pos.y-1) * self.style.room_size)
    else
        love.graphics.translate(-self.dx, -self.dy)
    end
    --rooms
    for i, r in pairs(ROOMS.scenes) do
        if r.visited or r.reached or collideWithRoom(r.pos, ROOM.pos) then
            local c = 0.5 + booltonumber(r.visited) / 2
            love.graphics.setColor(c, c, c, 1)
            love.graphics.rectangle(
                'fill',
                r.pos.x  * self.style.room_size - self.style.room_size * 1.5 + self.style.room_ofset * r.pos.x  + x,
                -r.pos.y * self.style.room_size + self.style.room_size / 2   + self.style.room_ofset * -r.pos.y + y,
                self.style.room_size, self.style.room_size
            )
            local icon = Assets.icons[r.type]
            if icon then
                love.graphics.draw(
                    icon,
                    r.pos.x  * self.style.room_size - self.style.room_size * 1.5 + self.style.room_ofset * r.pos.x  + x,
                    -r.pos.y * self.style.room_size + self.style.room_size / 2   + self.style.room_ofset * -r.pos.y + y,
                    0,
                    self.style.room_size / icon:getWidth(),
                    self.style.room_size / icon:getHeight()
                )
            end
        end
    end
    --current room
    love.graphics.setColor(1, 0, 0, a)
    local p = ROOM.pos
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line',
        p.x    * self.style.room_size - self.style.room_size * 1.5 + self.style.room_ofset * p.x    + x,
        (-p.y) * self.style.room_size + self.style.room_size / 2   + self.style.room_ofset * (-p.y) + y,
        self.style.room_size,
        self.style.room_size
    )

    love.graphics.pop()
    --border line
    love.graphics.setLineWidth(4)
    love.graphics.setColor(1, 1, 1, a)
    love.graphics.rectangle('line', x-sx/2, y-sy/2, sx/2*2, sy/2*2)
    love.graphics.setLineWidth(0)

    love.graphics.stencil(function ()
        love.graphics[CURTAIN.shape](unpack(CURTAIN.args))
    end, 'replace')

    if self.style.level_name then
        local f = love.graphics.setNewFont(Assets.fonts.visitor, 27)
        local lsx, lsy = f:getWidth(LEVEL.name), f:getHeight(LEVEL.name)
        love.graphics.print(LEVEL.name, x-lsx/2, y+sy/2)
    end
end

function minimap:setStyle(s)
    for k, v in pairs(s) do
        assert(self.style[k] ~= nil, k .. ' style element in Minimap is not exists!')
        assert(type(self.style[k]) == type(v), k .. ' value type must be a ' .. type(self.style[k]) .. ' (found ' .. type(v) .. ')')
        self.style[k] = v
    end
    return self
end

function minimap:update(dt)
    if     love.keyboard.isDown(CONTROLS.walk.up)    then self.dy = self.dy - 10
    elseif love.keyboard.isDown(CONTROLS.walk.down)  then self.dy = self.dy + 10 end
    if     love.keyboard.isDown(CONTROLS.walk.right) then self.dx = self.dx + 10
    elseif love.keyboard.isDown(CONTROLS.walk.left)  then self.dx = self.dx - 10 end
end

return minimap