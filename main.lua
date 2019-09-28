love.graphics.setDefaultFilter('nearest', 'nearest')

class = love.filesystem.load('lib/class.lua')()
json  = love.filesystem.load('lib/json.lua')()
loader = love.filesystem.load('lib/loader.lua')()()

RUN_ARGUMENTS = json.decode( love.filesystem.read('run_arguments.txt') )

local old_print = love.graphics.print
function love.graphics.print(s, x, y, ...)
    x, y = math.floor(x), math.floor(y)
    old_print(s, x, y, ...)
end

local build_ent_class_by_json = love.filesystem.load('entities/build_json.lua')()

function love.load()
    print('--lib loading started!--')
    loader:setFile('lib/list.json')
    
    function loader.onFileLoad(key, obj, path)
        print('  ' .. path)
        _G[key] = obj
    end

    function loader.onDone(result)
        print('--lib loading completed!--', '\n')
        print('--assets loading started!--')

        function loader.onFileLoad(key, obj, path)
            print('  ' .. path)
        end

        loader:setFile('assets/list.json')
        loader:load()
        result = nil

        function loader.onDone(result)
            _G.Assets = result.assets
            print('--assets loading completed!--', '\n')
            print('--entities loading started!--')

            loader:setFile('entities/list.json')
            loader:load()
            result = nil

            _G.EntityClasses = {}
            function loader.onFileLoad(key, obj, path)
                print('  ' .. path)
                if not obj.is then
                    obj = build_ent_class_by_json(obj)
                end
                _G.EntityClasses[key] = obj
                for i, b in ipairs{'Projectile', 'Weapon', 'Mob'} do
                    if key == b then
                        _G[key] = obj
                    end
                end
            end

            function loader.onDone(result)
                print('--entities loading completed!--', '\n')
                print('--scenes loading started!--')

                loader:setFile('scenes/list.json')
                loader:load()
                result = nil

                function loader.onFileLoad(key, obj, path)
                    print('  ' .. path)
                    _G[key] = obj
                end

                function loader.onDone(result)
                    print('--scenes loading completed!--')
                    love.filesystem.load('init.lua')()
                end

            end

        end

    end

    loader:load()
end

function love.update(dt)
    loader:update(dt)
end

function love.draw()          end
function love.mousepressed()  end
function love.mousereleased() end
function love.keypressed()    end
function love.keyreleased()   end