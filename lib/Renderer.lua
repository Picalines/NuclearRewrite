local Renderer = class()

function Renderer:new()
    self.handlers = {}
end

function Renderer:add(layer, func, ...)
    local h = self.Handler(self, func, layer, ...)
    table.insert(self.handlers, h)
    self:sort_handlers()
    return h
end

function Renderer:remove(handler)
    handler = handler or self.handlers[#self.handlers]
    table.remove(self.handlers, handler.id)
    self:sort_handlers()
end

function Renderer:draw()
    for i, hand in pairs(self.handlers) do hand:draw() end
end

function Renderer:sort_handlers()
    if #self.handlers <= 1 then return end
    table.sort(self.handlers, function (a, b) return a.layer < b.layer end)
    for i, hand in pairs(self.handlers) do
        hand.id = i
    end
end

Renderer.Handler = class()

function Renderer.Handler:new(renderer, func, layer, ...)
    self.renderer = renderer
    assert(func ~= nil, "'draw' or 'render' function in renderer is nil!")
    if type(func) == 'table' then
        assert(func.draw ~= nil or func.render ~= nil, "'draw' or 'render' function in renderer is nil!")
        func = func.draw or func.render
    end
    if layer ~= nil then
        assert(type(layer) == 'number', 'layer in renderer must be a number!')
    end
    layer = layer or self.renderer.handlers[#self.renderer.handlers].layer+1
    self.args = {...}
    self.func = func
    self.layer = layer
end

function Renderer.Handler:draw()
    self.func(unpack(self.args))
end

return Renderer