local loader = class()

function loader:new(filename)
    if filename then
        self:setFile(filename)
    end
end

function loader:setFile(filename)
    self.file = json.decode( love.filesystem.read(filename) )
    self.file = json.decode( love.filesystem.read(filename) )
    self.loaded = {}
    self.done = false
    self.total_done = false
end

local function getFormat(url)
    return tostring( tostring(url):match("^.+(%..+)$") )
end

function loader:update(dt)
    if self.done and not self.total_done then
        self.total_done = true
        self.onDone(self.loaded)
        return true
    end
end

function loader.onDone(result)
    --custom trigger
end

function loader.onFileLoad(key, obj, filename)
    --custom trigger
end

function loader:isDone()
    return self.total_done
end

function loader:load(tbl, path, storage)
    if self.done and self.total_done then
        self.done = false
        self.total_done = false
        self.loaded = {}
    end
    tbl = tbl or self.file
    path = path or tbl.folder or ""
    storage = storage or self.loaded
    local currentKey = nil
    local old_update = self.update
    function self:update(dt)
        currentKey = next(tbl, currentKey)
        local value = tbl[currentKey]
        self.done = (value == nil)
        if self.done then
            self.update = old_update
        else
            if value.folder then
                storage[value.key] = {}
                self:load(value.files, path .. value.folder .. "/", storage[value.key])
            else
                if not value.cantFindFileErrorProtect then
                    assert(love.filesystem.getInfo(path .. value.name), "can't find file: " .. path .. value.name)
                end
                local ok, msg = pcall(function ()
                    storage[value.key] = self.formats[getFormat(value.name)](path .. value.name)
                    self.onFileLoad(value.key, storage[value.key], path .. value.name)
                end)
                if not ok then
                    if not self.formats[getFormat(value.name)] then
                        error('format ' .. getFormat(value.name) .. ' is not supported! (file name: ' .. tostring(value.name) .. ')')
                    else
                        error(msg)
                    end
                end
            end
        end
    end
end

loader.formats = {}

--images
loader.formats['.png'] = function (name)
    return love.graphics.newImage(name)
end

loader.formats['.jpg'] = loader.formats['.png']

--txt
loader.formats['.lua'] = function (name)
    --return love.filesystem.load(name)()
    return require(name:sub(0, #name-4))
end

loader.formats['.txt'] = function (name)
    return love.filesystem.read(name)
end

loader.formats['.json'] = function (name)
    return json.decode( love.filesystem.read(name) )
end

--sounds
loader.formats['.wav'] = function (name)
    return love.audio.newSource(name, 'static')
end

loader.formats['.ogg'] = loader.formats['.wav']

loader.formats['.mp3'] = function (name)
    return love.audio.newSource(name, 'stream')
end

--fonts
loader.formats['.ttf'] = function (name)
    return name
end

return loader