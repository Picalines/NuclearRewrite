local Animation = class()

--[[anim type class]]--
Animation.type = class()

function Animation.type:new(quads, sf, ef, style, calls)
    self.frames = {}
    for i = sf, ef do
        self.frames[i-sf+1] = quads[i]
    end

    self.time = 0
    self.frame = 1
    self.playing = true

    self.style = {
        loop  = true,
        speed = 0.2
    }
    self:setStyle(style or {})

    self.callbacks = {
        onStart    = function () end,
        onEnd      = function () end,
        onNewFrame = function () end
    }
    self:setCallback(calls or {})

end

function Animation.type:setStyle(s)
    for k, v in pairs(s) do
        assert( type(self.style[k]) == type(v), k .. ' animation type style parameter type must be ' .. type(self.style[k]) .. '! (found ' .. type(v) .. ')' )
        self.style[k] = v
    end
end

function Animation.type:setCallback(c)
    for k, v in pairs(c) do
        assert( type(self.callbacks[k]) == type(v), k .. ' animation type callback parameter type must be ' .. type(self.callbacks[k]) .. '! (found ' .. type(v) .. ')' )
        self.callbacks[k] = v
    end
end

function Animation.type:getFrame()
    return self.frames[self.frame]
end

function Animation.type:update(dt)
    self.time = self.time + dt
    if self.time > self.style.speed then
        self.time = 0
        self.frame = self.frame + 1
        if self.frame > #self.frames then
            self.frame = #self.frames
            if self.style.loop then
                self.playing = true
                self.frame = 1
                self.callbacks:onEnd()
                self.callbacks:onStart()
                self.callbacks:onNewFrame(self.frame)
            elseif self.playing then
                self.playing = false
                self.callbacks:onEnd()
            end
        else
            self.callbacks:onNewFrame(self.frame)
        end
    end
end

--[[anim class]]--
function Animation:new(source, fsx, fsy)
    if type(source) == 'string' then
        self.source = love.graphics.newImage(source)
    else
        self.source = source
    end
    self.types = {}
    self.type = ''

    self.quads = {}
    local w, h = self.source:getDimensions()
    for y = 0, h / fsy - 1 do
        for x = 0, w / fsx - 1 do
            self.quads[#self.quads+1] = love.graphics.newQuad(
                x * fsx,
                y * fsy,
                fsx, 
                fsy,
                w,
                h
            )
        end
    end

end

function Animation:addType(name, ...)
    self.types[name] = Animation.type(self.quads, ...)
    return self.types[name]
end

function Animation:setType(name)
    assert(self.types[name], "can't find " .. tostring(name) .. " animation type")
    self.type = name
    self.types[self.type].callbacks:onStart()
    self.types[self.type].callbacks:onNewFrame(self.types[self.type].frame)
    return self.types[self.type]
end

function Animation:getType(name)
    name = name or self.type
    assert(self.types[name], "can't find " .. tostring(name) .. " animation type")
    return self.types[name]
end

function Animation:update(dt)
    self.types[self.type]:update(dt)
end

function Animation:draw(...)
    love.graphics.draw(self.source, self.types[self.type]:getFrame(), ...)
end

return Animation