local GameScreen = class(Scene)

GameScreen.name = 'GameScreen'

function GameScreen:load()
    self.Timer = Timer.new()
    TIME = Timer.new()

    --Game state
    self.PLAYING = true
    _G.PLAYING   = true

    --Pause menu buttons
    local ofset, size = 80-64, vec2(64, 64)

    self.pause_menu.UI:add(Button, vec2(size.x/2+ofset, 0), size):setStyle({
        sprite = Assets.PauseMenu.play
    }):setCallback{
        mouseUp = function ()
            self:pause()
        end
    }

    --restart button
    --self.pause_menu.UI:add(Button, vec2(size.x*1.5+ofset, 0), size):setStyle({
    --    sprite = Assets.PauseMenu.restart
    --}):setCallback{
    --    mouseUp = function ()
    --        SCENES:switch('MainMenu')
    --        SCENES:switch('GameScreen')
    --    end
    --}

    self.pause_menu.UI:add(Button, vec2(size.x*1.5+ofset, 0), size):setStyle({
        sprite = Assets.PauseMenu.quit
    }):setCallback{
        mouseUp = function ()
            SCENES:switch('MainMenu')
        end
    }

    for i, b in pairs(self.pause_menu.UI.elements) do
        b:setStyle{ caption = "" }
    end

    --GUIs
    self.GUI.hp_bar = self.GUI:add(SpriteBar, vec2(10, HEIGHT-Assets.icons.hp_bar_part:getHeight()*4-10), Assets.icons.hp_bar_part, 5):setStyle{
        dir   = 'up',
        scale = 4,
        ofset = -1
    }

    self.GUI.ammo_bar = self.GUI:add(SpriteBar, vec2(WIDTH-10 - Assets.icons.bullet_ammo:getWidth()*4, HEIGHT-Assets.icons.bullet_ammo:getHeight()*4-10), Assets.icons.bullet_ammo, 0):setStyle{
        dir   = 'up',
        scale = 4,
        ofset = -1
    }

    self.GUI.weapon_info = self.GUI:add(Label, vec2(WIDTH/2, HEIGHT-35), vec2(400, 50)):setStyle{
        strokecolor  = color(1, 1, 1, 1),
        strokewidth  = 0,
        backcolor    = color(0, 0, 0, 0),
        textcolor    = color(1, 1, 1, 0),
        font         = love.graphics.newFont(Assets.fonts.visitor, 30),
        text         = 'none'
    }

    self.minimap = Minimap(110, 80, 200, 140):setStyle{
        fixed      = true,
        room_size  = 32,
        background = color(0.2, 0.2, 0.2, 0.5)
    }

end

function GameScreen:enter(planet)
    love.graphics.setBackgroundColor(0, 0, 0)
    math.randomseed(os.time())

    self.PLAYING = true
    self.pause_menu.ofset = 0
    self.pause_menu.bw_size = 0
    for i, b in pairs(self.pause_menu.UI.elements) do
        b.pos.y = -((100+80-64)/2)
    end

    local planets_data = Assets.Space.planets_data
    local roomscount = planets_data.size_types[planet.size_type].rooms
    self.level = Level(planet.name, planet.maps_folder, math.random(roomscount[1], roomscount[2]))
    _G.LEVEL   = self.level

    self.curtain = color(0, 0, 0, 1)

    self.GUI.hp_bar.count = 5
    self.GUI.hp_bar.max   = 5

end

function GameScreen:update(dt)
    if not self.level.generated then
        if self.level:generate() then
            if not (ROOMS and START_ROOM and ROOM) then SCENES:switch('MainMenu') return end
            self:onGenerationDone()
        end
        return
    end
    _G.PLAYING = self.PLAYING
    if self.PLAYING then
        if not (love.window.hasMouseFocus() or love.window.hasFocus()) and self.PLAYING then
            self:pause()
            return
        end
        self.level:update(dt)
        TIME:update(dt)
        self.GUI:update(dt)
    elseif self.pause_menu.ofset > 32 then
        self.minimap:update(dt)
    end
    self.pause_menu:update()
    self.Timer:update(dt)
end

function GameScreen:draw()
    if not self.level.generated then
        love.graphics.setColor(1, 1, 1, math.abs(math.sin(love.timer.getTime()*5)))
        love.graphics.print('generating...', 30, HEIGHT-60)
        return
    end

    love.graphics.setShader(Assets.shaders.bw)
    love.graphics.getShader():send('size', self.pause_menu.bw_size)
    self.level:draw()
    love.graphics.setColor(self.curtain)
    love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
    self.GUI:draw()
    love.graphics.setShader()

    self.pause_menu:draw()
    self.minimap:draw(1-self.pause_menu.ofset/(100+80-64))
end

--Pause menu
GameScreen.pause_menu = {
    UI    = UI(),
    ofset = 0,
    bw_size = 0,
    animating = false
}

function GameScreen.pause_menu:draw()
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle('fill', 0, 0, WIDTH, self.ofset)
    love.graphics.setColor(255, 255, 255, 255)
    self.UI:draw()
end

function GameScreen.pause_menu:update() self.UI:update() end
function GameScreen.pause_menu:mousepressed(x, y, but) self.UI:mousepressed(x, y, but) end
function GameScreen.pause_menu:mousereleased(x, y, but) self.UI:mousereleased(x, y, but) end

--curtain
GameScreen.curtain = color(0, 0, 0, 1)

--GUI
GameScreen.GUI = UI()
_G.GUI = GameScreen.GUI

function GUI:weaponInfoAnimPlay(weap)
    local info = weap.info
    self.ammo_bar.style.color = info.ammo_bar_color
    self.weapon_info:setStyle{
        backcolor   = color(0, 0, 0, 1),
        textcolor   = info.namecolor,
        strokewidth = 4,
        text        = info.name
    }

    self.weapon_info.pos.y = HEIGHT+35
    TIME:tween(0.3, self.weapon_info.pos, { y = HEIGHT-35 }, 'in-out-back', function ()
        TIME:after(1, function ()
            self.weapon_info.style.text = info.description
        end)
        TIME:after(3, function ()
            TIME:tween(0.3, self.weapon_info.pos, { y = HEIGHT+35 }, 'in-out-back', function ()
                self.weapon_info:setStyle{
                    backcolor   = color(0, 0, 0, 0),
                    textcolor   = color(1, 1, 1, 0),
                    strokewidth = 0
                }
            end)
        end)
    end)
end

function GUI:ammoBarUpdate(weap)
    if weap then
        self.ammo_bar.style.tintcolor = weap.info.ammo_bar_color
        self.ammo_bar.pos.x = WIDTH-10 - Assets.icons.bullet_ammo:getWidth()*4
        local ammo = weap.ammo
        self.ammo_bar.max    = ammo.maxholder
        self.ammo_bar.count  = ammo.holder
        self.ammo_bar.sprite = weap.info.ammo_bar_sprite
    else
        self.ammo_bar.pos.x = WIDTH+10
    end
end

function GameScreen:onGenerationDone()
    self.PLAYING = true
    self.Timer:tween(1, self.curtain, {a = 0}, 'linear', function ()
        self.curtain = color(START_ROOM.tiledmap.backgroundcolor:get()) 
        self.curtain.a = 0
    end)
    self.GUI.hp_bar.count = Player.hp.count
    self.GUI.hp_bar.max   = Player.hp.max
end

function GameScreen:pause()
    if self.pause_menu.animating then return end
    self.PLAYING = not self.PLAYING
    self.pause_menu.animating = true
    if self.PLAYING then
        self.PLAYING = false
        self.Timer:tween(0.3, self.pause_menu, {ofset = 0, bw_size = 0}, 'in-back', function ()
            self.PLAYING = true
            self.pause_menu.animating = false
        end)
        for i, b in pairs(self.pause_menu.UI.elements) do
            self.Timer:tween(0.3, b.pos, {y = -((100+80-64)/2)}, 'in-back')
        end
    else
        self.Timer:tween(0.3, self.pause_menu, {ofset = 100+80-64, bw_size = 1}, 'out-back', function ()
            self.pause_menu.animating = false
        end)
        for i, b in pairs(self.pause_menu.UI.elements) do
            self.Timer:after(i/30, function ()
                self.Timer:tween(0.3, b.pos, {y = (100+80-64)/2}, 'out-back')
            end)
        end
    end
end

function GameScreen:playerDeath()
    CURTAIN.shape = 'ellipse'
    CURTAIN.args  = {'fill', WIDTH/2, HEIGHT/2, WIDTH}
    TIME:tween(1.3, CURTAIN.args, { [4] = 0 }, 'linear', function ()
        CURTAIN:reset()
        SCENES:switch('MainMenu')
    end)
end

function GameScreen:keypressed(key)
    if key == CONTROLS.game.pause then
        self:pause()
    elseif key == 'tab' then
        if self.minimap.extended then
            self.Timer:tween(0.5, self.minimap, {sx = 200, sy = 140, x = 110, y = 80},  'out-back')
        else
            self.Timer:tween(0.5, self.minimap, {sx = 300, sy = 240, x = 160, y = 130}, 'out-back')
        end
        self.minimap.extended         = not self.minimap.extended
        self.minimap.style.level_name = not self.minimap.style.level_name
    else
        self.level:keypressed(key)
    end
end

function GameScreen:mousepressed(x, y, but)
    if self.PLAYING then
        self.level:mousepressed(x, y, but)
    else
        self.pause_menu:mousepressed(x, y, but)
    end
end

function GameScreen:mousereleased(x, y, but)
    if self.PLAYING then
        self.level:mousereleased(x, y, but)
    else
        self.pause_menu:mousereleased(x, y, but)
    end
end

return GameScreen