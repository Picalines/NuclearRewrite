if not GLOBALS_LOADED then
    GLOBALS_LOADED = true

    love.window.maximize()
    SCREEN_SIZE = vec2(love.graphics.getDimensions())

    RESOLUTION = vec2(RUN_ARGUMENTS.resolution.width, RUN_ARGUMENTS.resolution.height)

    local scale = RUN_ARGUMENTS.window.scale
    love.window.setMode(RESOLUTION.x * scale, RESOLUTION.y * scale, {resizable = RUN_ARGUMENTS.window.resizable})
    CScreen.init(RESOLUTION.x, RESOLUTION.y, RUN_ARGUMENTS.window.centered)

    math.randomseed(os.time())
    love.mouse.setVisible(RUN_ARGUMENTS.window.mouse_visible)

    if RUN_ARGUMENTS.window.fullscreen then
        love.window.setFullscreen(true)
    end

    WIDTH = RESOLUTION.x
    HEIGHT = RESOLUTION.y

    ElapsedTime = 0
    DeltaTime = 0

    --controls
    if not love.filesystem.getInfo("controls.json") then
        love.filesystem.write("controls.json", love.filesystem.read("options/controls.json"))
    end
    CONTROLS = json.decode(love.filesystem.read("options/controls.json"))

    --Console ('~' to open)
    CONSOLE = Console()
    function print(...)
        CONSOLE:print({...}, color(1, 1, 1, 1))
    end

    function colorPrint(s, clr)
        CONSOLE:print(s, clr)
    end

    --debug table
    DEBUG = {
        showHitBoxes = false,
        showFPS = false,
        generationNED = false --Not enough doors error
    }

    --Scenes
    SCENES = SceneManager(MainMenu, GameScreen, Space)

    --Curtain for transitions
    CURTAIN = {
        shape = "rectangle",
        args = {"fill", 0, 0, WIDTH, HEIGHT},
        reset = function(self)
            self.shape = "rectangle"
            self.args = {"fill", 0, 0, WIDTH, HEIGHT}
        end
    }

    function love.load()
        CURSOR = Cursor()
        SCENES:switch("MainMenu")
    end
    love.load()
end

function love.update(dt)
    dt = math.min(dt, 1 / 30)
    DeltaTime = dt
    ElapsedTime = love.timer.getTime()
    CURSOR:update()
    if not CONSOLE:isOpened() then
        local ok, msg = pcall(SCENES.update, SCENES, dt)
        if not ok then
            colorPrint(msg, color(1, 0, 0))
        end
    end
end

function love.draw()
    CScreen.apply()

    local ok, msg = pcall(
        function()
            love.graphics.stencil(
                function()
                    love.graphics[CURTAIN.shape](unpack(CURTAIN.args))
                end,
                "replace"
            )
            love.graphics.setStencilTest("equal", 1)
            SCENES:draw()
        end
    )
    if not ok and not CONSOLE:isOpened() then
        colorPrint(msg, color(1, 0, 0))
    end
    if DEBUG.showFPS then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print(love.timer.getFPS(), 5)
    end

    CONSOLE:draw()
    CURSOR:draw()

    CScreen.cease()
end

function love.keypressed(key)
    if not CONSOLE:isOpened() then
        SCENES:keypressed(key)
    end
    CONSOLE:keypressed(key)
end

function love.textinput(txt)
    if txt == CONTROLS.game.console and not CONSOLE:isOpened() then
        CURTAIN:reset()
        CONSOLE:open()
        return
    end
    if CONSOLE:isOpened() then
        CONSOLE:textinput(txt)
    end
end

function love.keyreleased(key)
    if not CONSOLE:isOpened() then
        SCENES:keyreleased(key)
        if key == CONTROLS.game.screenshot then
            local screenshot = love.graphics.captureScreenshot(os.time() .. ".png")
            print("screenshot saved to: \\AppData\\Roaming\\LOVE\\Nuclear rewrite\\" .. os.time() .. ".png")
        end
    end
end

function love.mousepressed(x, y, but)
    if not CONSOLE:isOpened() then
        SCENES:mousepressed(CURSOR.x, CURSOR.y, but)
    end
end

function love.mousereleased(x, y, but)
    if not CONSOLE:isOpened() then
        SCENES:mousereleased(CURSOR.x, CURSOR.y, but)
    end
end

function love.resize(w, h)
    CScreen.update(w, h)
end
