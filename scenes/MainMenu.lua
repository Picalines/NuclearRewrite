local MainMenu = class(Scene)

MainMenu.name = 'MainMenu'

function MainMenu:load()
    --Background
    self.stars = {}
    self.curtain = {
        size = {
            width = 0, height = HEIGHT
        },
        color = color(0.3, 0.3, 0.47, 0.78)
    }
    --Ship
    self.ship = {
        pos = vec2(-WIDTH/2, HEIGHT/2+HEIGHT/4),
        anim = Animation(Assets.MainMenu.space_ship, 118, 72)
    }
    self.ship.anim:addType('fly', 1, 2, {speed = 0.1})
    self.ship.anim:setType('fly')

    --UI
    self.UI = UI()
    self.Timer = Timer.new()

    --spawning stars
    self.Timer:every(0.05, function ()
        local r = math.random
        self:star(vec3(WIDTH+100, r(-10, HEIGHT+10), r(1,100)/10), color(r(10,255)/255, r(10,255)/255, r(10,255)/255))
    end)

    local ofset = 130

    --Main
    self.UI:add(Button, vec2(-WIDTH/6, HEIGHT/2-ofset), vec2(170, 50)):setStyle({
        caption = 'PLAY'
    }):setCallback{
        mouseUp = function (b)
            local ofset = WIDTH/8
            for i, k in pairs(self.UI.elements) do
                if k.style.caption == 'PLAY' or k.style.caption == 'OPTIONS' or k.style.caption == 'QUIT' then
                    self.Timer:tween(0.35, k.pos, {x = -WIDTH+ofset},'out-expo')
                end
            end
            self.Timer:tween(0.35, self.curtain, { color = {a = 0}, size = {width = 0} }, 'out-expo', function ()
                CURTAIN.shape = 'ellipse'
                CURTAIN.args = {'fill', self.ship.pos.x, self.ship.pos.y, WIDTH}
                self.Timer:tween(1, CURTAIN.args, { [2] = WIDTH + WIDTH/4, [4] = 0 }, 'in-out-back')
                self.Timer:tween(0.8, self.ship.pos, { x = WIDTH + WIDTH/4 }, 'in-out-back', function ()
                    self.curtain.color = color(0, 0, 0, 0.01)
                    self.Timer:tween(0.4, self.curtain.size, {width = WIDTH}, 'in-back', function ()
                        b.pressed = false
                        SCENES:switch('Space')
                    end)
                end)
            end)
        end
    }

    self.UI:add(Button, vec2(-WIDTH/6, HEIGHT/2), vec2(290, 50)):setStyle({
        caption = 'OPTIONS'
    }):setCallback{
        mouseUp = function ()
            self:move_menu(WIDTH)
            self.Timer:tween(0.35, self.curtain, {
                color = {a = 1}, size = { width = WIDTH+WIDTH/6+170 }
            }, 'out-expo')
        end
    }

    self.UI:add(Button, vec2(-WIDTH/6, HEIGHT/2+ofset), vec2(170, 50)):setStyle({
        caption = 'QUIT'
    }):setCallback{
        mouseUp = function ()
            love.event.quit()
        end
    }

    --Options
    self.UI:add(Button, vec2(-WIDTH/6, HEIGHT/6), vec2(170, 50)):setStyle({
        caption = 'BACK'
    }):setCallback{
        mouseUp = function (b)
            self:move_menu(-WIDTH)
            self.Timer:tween(0.35, self.curtain, { color = {a = 0.78}, size = { width = WIDTH/6+290 } }, 'out-expo')
        end
    }
    
    self.UI:add(Button, vec2(-WIDTH/2, HEIGHT/2-55), vec2(420, 50)):setStyle({
        caption = 'FULLSCREEN'
    }):setCallback{
        mouseUp = function (b)
            --b.style.caption = "not working..."
            --self.Timer:after(0.5, function ()
            --    b.style.caption = 'FULLSCREEN'
            --end)
            love.window.setFullscreen( not love.window.getFullscreen() )
        end
    }

    self.UI:add(Button, vec2(-WIDTH/2, HEIGHT/2), vec2(340, 50)):setStyle({
        caption = 'CONTROLS'
    }):setCallback{
        mouseUp = function (b)

        end
    }

    self.msg_controls_label = self.UI:add(Label, vec2(-WIDTH/2, HEIGHT+HEIGHT/2), vec2(200,100)):setStyle{
        textcolor = color(1, 1, 1),
        text = "I want to change ...",
        font = love.graphics.newFont(Assets.fonts.visitor, 40)
    }

    for i, el in pairs(self.UI.elements) do
        if el:is(Button) then
            el:setStyle{
                font = love.graphics.newFont(Assets.fonts.visitor, 70),
                color = color(0, 0, 0, 0)
            }

            local old = el.callbacks.mouseUp
            el:setCallback{
                mouseDown = function (b)
                    b.style.capcolor = color(0.78, 0.78, 0.78, 1)
                end,
                mouseUp = function (b)
                    old(el)
                    b.style.capcolor = color(1, 1, 1, 1)
                end
            }
        end
    end

end

function MainMenu:move_menu(dx, dy)
    dx, dy = dx or 0, dy or 0
    for i, k in pairs(self.UI.elements) do
        self.Timer:tween(0.35, k.pos, {x = k.pos.x + dx, y = k.pos.y + dy}, 'out-expo')
    end
end

function MainMenu:enter()
    --self:load()/3
    self.Timer = Timer.new()

    self.ship.pos = vec2(-WIDTH/2, HEIGHT/2+HEIGHT/4)

    self.stars = {}
    for i = 1, 39 do
        local r = math.random
        self:star(vec3(r(-50, WIDTH+50), r(-50, HEIGHT), r(1,100)/10), color(r(10,255)/255, r(10,255)/255, r(10,255)/255))
    end

    --spawning stars
    self.Timer:every(0.03, function ()
        local r = math.random
        self:star(vec3(WIDTH+100, r(-10, HEIGHT+10), r(1,100)/10), color(r(10,255)/255, r(10,255)/255, r(10,255)/255))
    end)

    self.curtain.size.width = 0

    self.curtain.color = color(0.3, 0.3, 0.47, 0.78)
    self.Timer:tween(0.5, self.curtain.size,  { width = WIDTH/6+290}, 'out-expo')
    self.Timer:tween(0.5, self.ship.pos, {x = WIDTH/2, y = HEIGHT/2}, 'out-expo')
    
    local ofset = WIDTH/8+85
    for i, k in pairs(self.UI.elements) do
        if k.style.caption == 'PLAY' or k.style.caption == 'OPTIONS' or k.style.caption == 'QUIT' then
            self.Timer:tween(0.5, k.pos, {x = ofset}, 'out-expo')
        end
    end

end

function MainMenu:star(pos, clr)
    local s = {}
        s.pos   = pos
        s.color = clr
        s.speed = s.pos.z*1.25
    table.insert(self.stars, s)
    --table.sort(self.stars, function (a,b) return a.pos.z < b.pos.z end)
end

function MainMenu:update(dt)
    --Background
    --Moving stars
    for i, s in pairs(self.stars) do
        s.pos.x = s.pos.x - s.speed * 150 * dt
        if s.pos.x < -100 then
            self.stars[i] = nil
        end
    end
    --Ship
    self.ship.anim:update(dt)
    local sx, sy = Assets.MainMenu.space_ship:getDimensions()
    if self.ship.pos.x < WIDTH then
        for i = 1, 4 do
            self:star(vec3(
                self.ship.pos.x+math.sin(love.timer.getTime())*WIDTH/14+15,
                self.ship.pos.y+math.cos(love.timer.getTime()*1.5)*HEIGHT/8+sy/2+5+math.random(-8,8),
                math.random(20,40)/5),
                color((153+math.random(0,-50))/255, (102+math.random(0,-50))/255, (255+math.random(0,-80))/255)
            )
        end
    end
    --UI
    self.UI:update(dt)
    --Tweens
    self.Timer:update(dt)
end

function MainMenu:mousepressed(x, y, but)
    self.UI:mousepressed(x, y, but)
end

function MainMenu:mousereleased(x, y, but)
    self.UI:mousereleased(x, y, but)
end

function MainMenu:draw()
    love.graphics.background(0.06, 0.06, 0.06)
    if self.curtain.color.a < 255 then
        --Stars
        for i, s in pairs(self.stars) do
            love.graphics.setColor(s.color.r, s.color.g, s.color.b, math.sin(ElapsedTime*s.pos.z)*0.5)
            love.graphics.rectangle('fill', s.pos.x-2, s.pos.y-2, s.pos.z+4, s.pos.z+4)
            love.graphics.setColor(s.color)
            love.graphics.rectangle('fill', s.pos.x, s.pos.y, s.pos.z, s.pos.z)
        end
        love.graphics.setColor(255,255,255,255)
        --Ship
        if self.ship.pos.x < WIDTH then
            self.ship.anim:draw(
                self.ship.pos.x + math.sin(love.timer.getTime()) * WIDTH/14,
                self.ship.pos.y + math.cos(love.timer.getTime()*1.5) * HEIGHT/8
            )
        end
    end
    --UI
    love.graphics.setColor(self.curtain.color)
    love.graphics.rectangle('fill', 0, 0, self.curtain.size.width, self.curtain.size.height)
    self.UI:draw()
end

function MainMenu:keypressed(key)
    if key == CONTROLS.game.pause then
        love.event.quit()
    end
end

return MainMenu