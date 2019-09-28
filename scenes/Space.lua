local Space = class(Scene)
Space.name = 'Space'

function Space:load()
    --animation
    self.Timer = Timer.new()

    --planet sprites
    self.planet_quads = {}
    for y = 0, (Assets.Space.planets:getHeight() / 32) - 1 do
        self.planet_quads[y+1] = {}
        for x = 0, (Assets.Space.planets:getWidth() / 32) - 1 do
            self.planet_quads[y+1][x+1] = love.graphics.newQuad(x*32, y*32, 32, 32, Assets.Space.planets:getDimensions())
        end
    end

    --camera
    self.camera = Camera()
    self.camera.smooth = 0.8

    --ship particles
    self.particles = particleSystem()

    

end

function Space:enter()
    CURSOR.visible = false
    --planets
    self.planets = {}
    local x, y = 0, -30
    local y_dir = math.sign(math.random(-2, 1))
    for i = 1, 20 do
        x = x + (math.random(-10, 10)/10) * 120
        y = y + math.randomFloat(0, 1)  * 80 * y_dir
        self.planets[i] = self.planet(self, x, y, math.random(1, #Assets.Space.planets_data.templates))
    end

    for i = 1, 20 do
        --if math.random(0, 10) > 3 then
            self.planets[20+i] = self.planet(self, nil, nil, 1)
        --end
    end

    table.sort(self.planets, function (a, b) return a.pos.z < b.pos.z end)

    --ship
    self.ship   = {
        pos   = vec2(0, 300),
        start = vec2(),
        fuel  = 14, --*10
        vel   = vec2(),
        rot   = 0,
        scale = 1.7
    }

    self.background = Assets.Space.backgrounds[math.random(1, #Assets.Space.backgrounds)]
    self.background_color = color(math.randomFloat(0, 1), math.randomFloat(0, 1), math.randomFloat(0, 1), 0.2)

    local old_update = self.update
    function self:update(dt)
        self.Timer:update(dt)
    end

    CURTAIN.shape = 'rectangle'
    CURTAIN.args  = {'fill', WIDTH/2, HEIGHT/2, 0, 0}

    self.Timer:after(0.3, function ()
        self.Timer:tween(1, self.ship.pos, {y = 0}, 'out-expo')
        self.Timer:tween(1.1, CURTAIN.args, { [2] = 0, [3] = 0, [4] = WIDTH, [5] = HEIGHT }, 'out-back', function () CURTAIN:reset() end)
        self.Timer:tween(1, self.camera, {zoom = 1.2}, 'out-expo', function ()
            self.update = old_update
        end)
    end)
end

function Space:exit()
    CURSOR.visible = true
end

function Space:draw()
    love.graphics.background(0.06, 0.06, 0.06)
    self.camera:set(self.ship.pos.x, self.ship.pos.y)

    love.graphics.setColor(self.background_color)
    local w, h = self.background:getWidth(), self.background:getHeight()
    love.graphics.draw(self.background, 0, 0, 0, w/WIDTH * 1.5, h/HEIGHT * 1.5, w/2 + self.ship.pos.x / 60, h/2 + self.ship.pos.y / 60)

    love.graphics.setColor(1, 1, 1, (self.ship.start - self.ship.pos):len() / (self.ship.fuel * 10))
    love.graphics.ellipse('line', self.ship.start.x, self.ship.start.y, self.ship.fuel*10)
    

    self:getNearestPlanet()
    if self.planet_to_land then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.ellipse('line', self.planet_to_land.pos.x - self.ship.pos.x * self.planet_to_land.pos.z, self.planet_to_land.pos.y - self.ship.pos.y * self.planet_to_land.pos.z, self.planet_to_land.size*1.1)
    end

    --planets
    for i, pl in pairs(self.planets) do
        pl:draw(self.ship.pos.x, self.ship.pos.y)
    end

    --rauch
    self.particles:draw()

    --ship
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Assets.Space.space_ship, self.ship.pos.x, self.ship.pos.y, self.ship.rot, self.ship.scale, self.ship.scale, 5, 7)

    self.camera:unset()

    if self.planet_to_land then
        self:drawInfo(self.planet_to_land)
    end

end

function Space:update(dt)
    --animation
    self.Timer:update(dt)

    --move by keyboard
    local speed = 1.3
    if love.keyboard.isDown(CONTROLS.walk.right)     then self.ship.vel.x = self.ship.vel.x + speed
    elseif love.keyboard.isDown(CONTROLS.walk.left)  then self.ship.vel.x = self.ship.vel.x - speed end
    if love.keyboard.isDown(CONTROLS.walk.up)        then self.ship.vel.y = self.ship.vel.y - speed
    elseif love.keyboard.isDown(CONTROLS.walk.down)  then self.ship.vel.y = self.ship.vel.y + speed end

    --rotate by vel
    if self.ship.vel:len() > 2 then
        self.ship.rot = math.atan2(self.ship.vel.x, -self.ship.vel.y)
        self.particles:emit(Assets.particles.spaceship_trail, self.ship.pos.x, self.ship.pos.y, -self.ship.vel.x + math.random(-3, 3), -self.ship.vel.y + math.random(-3, 3), 0.2)
    end

    --move by vel
    self.ship.vel = self.ship.vel - self.ship.vel/5
    if (self.ship.start - self.ship.pos):len() > (self.ship.fuel * 10) then
        self.ship.vel = self.ship.vel + (self.ship.start - self.ship.pos) / 90
    end
    self.ship.pos = self.ship.pos + self.ship.vel

    --particles
    self.particles:update(dt)

end

function Space:keypressed(key)
    if key == CONTROLS.game.pause then
        SCENES:switch('MainMenu')
    elseif key == 'space' and self.planet_to_land then
        self:landOnPlanet()
    end
end

function Space:landOnPlanet()
    local old_update = self.update
    function self:update(dt) self.Timer:update(dt) end
    CURTAIN.shape = 'ellipse'
    CURTAIN.args = {'fill', WIDTH/2, HEIGHT/2, WIDTH/1.1}
    self.Timer:tween(1, self.ship, {scale = 0}, 'in-out-back')
    self.Timer:tween(2, CURTAIN.args, {[4] = 0}, 'in-back', function ()
        self.update = old_update
        SCENES:switch('GameScreen', {self.planet_to_land})
        CURTAIN:reset()
    end)
end

function Space:getNearestPlanet()
    local min, mi = nil, 1
    self.planet_to_land = nil
    for i, p in pairs(self.planets) do
        local dist = vec3(self.ship.pos.x, self.ship.pos.y, 1):dist(p.pos + vec3(-self.ship.pos.x * p.pos.z, -self.ship.pos.y * p.pos.z))
        if (dist < 24) and (dist < (min or dist + 1)) then
            min = dist
            mi = i
            self.planet_to_land = self.planets[i]
        end
    end
end

function Space:drawInfo(planet)
    local inf = 'name: ' .. planet.name .. '\nsize: ' .. planet.size_type .. '\ntype: ' .. planet.type .. '\n\npress space to land'
    local f = love.graphics.setNewFont(Assets.fonts.visitor, 22)
    local height = 110
    local scale = height/32/2
    local width = f:getWidth(inf) + 32*scale*2+20
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle('line', WIDTH-width-20, HEIGHT-height-20, width, height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', WIDTH-width-20, HEIGHT-height-20, width, height)
    love.graphics.push()
    love.graphics.translate(WIDTH-width-20, HEIGHT-height-20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Assets.Space.planets, planet.quad, 16*scale, height/2-16*scale, 0, scale)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', 0, 0, 32*scale*2, 32*scale*2)
    love.graphics.setLineWidth(1)
    love.graphics.print(inf, 32*scale*2+10, 5)
    love.graphics.pop()
end

Space.planet = class()

function Space.planet:new(sc, x, y, temp)
    --type by json data
    local planets_data = Assets.Space.planets_data
    if temp then
        self.info = planets_data.templates[temp]
    else
        self.info = table.random(planets_data.templates)
    end

    --parameters
    self.pos = vec3(x or math.random(-WIDTH/2, WIDTH/2), y or math.random(-HEIGHT/2, HEIGHT/2), math.randomFloat(1, 2)/2)

    --size
    self.size_type = table.random(self.info.size_type)
    self.size = math.random( planets_data.size_types[self.size_type].space[1], planets_data.size_types[self.size_type].space[1] )

    --type
    self.type = self.info.type

    --difficulty
    self.difficulty = self.info.difficulty

    --maps
    self.maps_folder = 'rooms/' .. tostring(self.info.maps_folder)

    --quad
    self.quad = sc.planet_quads[self.info.sprite_group][planets_data.size_types[self.size_type].sprite]

    --generate name
    self.name = ""
    local part = table.random(planets_data.name_parts)
    local parts_num = math.random(1, 3)

    for i = 1, parts_num do
        self.name = self.name .. part
        self.name = self.name .. "-"
        local new = part
        while new == part do
            new = table.random(planets_data.name_parts)
        end
        part = new
    end

    self.name = self.name:sub(0, #self.name-1)
    if math.random(0, 1) == 1 then
        self.name = self.name .. " " .. math.random( math.random(100, 200), math.random(701, 900) )
    end

end

function Space.planet:draw(dx, dy)
    love.graphics.push()
    love.graphics.translate(-dx * self.pos.z, -dy * self.pos.z)
    --love.graphics.setColor(self.color.r, self.color.g, self.color.b, 0.4)
    --love.graphics.rectangle('fill', (self.pos.x - self.size*1.5/2), (self.pos.y - self.size*1.5/2), self.size*1.5, self.size*1.5)
    --love.graphics.setColor(self.color.r, self.color.g, self.color.b, 1)
    --love.graphics.rectangle('fill', (self.pos.x - self.size/2), (self.pos.y - self.size/2), self.size, self.size)
    love.graphics.setColor(1, 1, 1, 1)
    local s = (self.size/32)*2
    love.graphics.draw(Assets.Space.planets, self.quad, (self.pos.x - self.size), (self.pos.y - self.size), 0, s, s)
    love.graphics.pop()
end


return Space