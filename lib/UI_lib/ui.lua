local UI = class()

function UI:new()
    self.elements = {}
end

UI.element = class()

UI.element.name = 'no_uiElement_name_found'

UI.element.style = {}
function UI.element:setStyle(s)
    for k, v in pairs(s) do
        assert(self.style[k] ~= nil, k .. ' style element in ' .. self.name .. ' is not exists!')
        assert(type(self.style[k]) == type(v), k .. ' value type must be a ' .. type(self.style[k]) .. ' (found ' .. type(v) .. ')')
        self.style[k] = v
    end
    return self
end

function UI.element:draw()     end 
function UI.element:update(dt) end
function UI.element:keypressed(key)  end
function UI.element:keyreleased(key) end
function UI.element:mousepressed(x, y, b)  end
function UI.element:mousereleased(x, y, b) end
function UI.element:textinput(txt) end

function UI:add(elClass, ...)
    assert(type(elClass) == 'table', 'Can not add element to UI as ' .. type(elClass) .. ' (table expected)')
    local newel = elClass(...)
    assert(newel:is(self.element), tostring(elClass) .. ' is not a UI.element!')
    self.elements[#self.elements+1] = newel
    return self.elements[#self.elements]
end

function UI:update(dt)
    for i, el in pairs(self.elements) do
        el:update(dt)
    end
end

function UI:draw()
    for i, el in pairs(self.elements) do
        el:draw()
    end
end

function UI:mousepressed(x, y, but)
    for i, el in pairs(self.elements) do
        el:mousepressed(x, y, but)
    end
end

function UI:mousereleased(x, y, but)
    for i, el in pairs(self.elements) do
        el:mousereleased(x, y, but)
    end
end

function UI:keypressed(key)
    for i, el in pairs(self.elements) do
        el:keypressed(key)
    end
end

function UI:keyreleased(key)
    for i, el in pairs(self.elements) do
        el:keyreleased(key)
    end
end

function UI:textinput(txt)
    for i, el in pairs(self.elements) do
        el:textinput(txt)
    end
end

return UI