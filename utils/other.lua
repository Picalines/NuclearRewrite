inf = 1e309 

function hex2rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x"..hex:sub(1, 2)) / 255, tonumber("0x"..hex:sub(3, 4)) / 255, tonumber("0x"..hex:sub(5, 6)) / 255
end

function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function booltonumber(v)
    return v and 1 or 0
end

function love.graphics.background(r, g, b)
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)
end

--function addActionToFunc(f, act)
--    return function (...)
--        f(...)
--        act()
--    end
--end