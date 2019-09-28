local console = class()

function console:new()
    self.opened = false
    
    self.input  = ""
    self.cursor = {
        pos   = 0,
        color = color(1, 0, 0)
    }

    self.inputs                  = {}
    self.CurrentInput            = 1
    self.history                 = {}
    self.fast_command            = false
    self.command_arguments_input = false

    self.style = {
        font = love.graphics.newFont(Assets.fonts.pixelType, 35)
    }

end

console.commands = love.filesystem.load('cnsl_commands.lua')()

function console:addCommand(name, f)
    assert(self.commands[name] == nil, name .. ' command is already exists!')
    assert(type(f) == 'function', 'console command type must be function!')
    self.commands[name] = f
end

function console:print(s, clr)
    if type(s) ~= 'table' then
        s = {s}
    elseif s == nil then
        s = '\n'
    end
    local fs = ""
    for k, v in pairs(s) do
        fs = fs .. tostring(v) .. '   '
    end
    table.insert(self.history, 1, {
        str = fs, clr = clr or color(1, 1, 1)
    })
end

function console:isOpened()
    return self.opened
end

function console:keypressed(key)
    if not self.opened then
        if key == '`' then
            self.opened = true
        end
    else
        if key == 'escape' then
            self.opened = false
        elseif key == 'backspace' then
            if self.cursor.pos > 0 then
                self.input = self.input:sub(0, self.cursor.pos-1) .. self.input:sub(self.cursor.pos+1, #self.input)
                self.cursor.pos = math.clamp(0, self.cursor.pos - 1, #self.input+1)
            end
        elseif key == 'return' and self.input ~= "" then
            while self.input:find(' ', #self.input) do
                self.input = self.input:sub(0, #self.input-1)
            end
            self:print('>> ' .. self.input)
            table.insert(self.inputs, 1, self.input)
            self:execute(self.input)
            self.CurrentInput = 0
            self.input = ""
            self.cursor.pos = 0
        elseif key == 'left' then
            self.cursor.pos = math.clamp(0, self.cursor.pos - 1, #self.input)
        elseif key == 'right' then
            self.cursor.pos = math.clamp(0, self.cursor.pos + 1, #self.input)
        elseif key == 'home' then
            self.cursor.pos = 0
        elseif key == 'end' then
            self.cursor.pos = #self.input
        elseif key == 'up' then
            if self.inputs[self.CurrentInput+1] then
                self.CurrentInput = self.CurrentInput + 1
                self.input = self.inputs[self.CurrentInput]
                self.cursor.pos = math.clamp(0, self.cursor.pos, #self.input)
            end
        elseif key == 'down' then
            if self.inputs[self.CurrentInput-1] then
                self.CurrentInput = self.CurrentInput - 1
                self.input = self.inputs[self.CurrentInput]
                self.cursor.pos = math.clamp(0, self.cursor.pos, #self.input)
            end
        end
    end
end

function console:textinput(txt)
    if self.opened and (txt ~= "`" and txt ~= '~') then
        self.input = self.input:sub(0, self.cursor.pos) .. txt .. self.input:sub(self.cursor.pos+1, #self.input)
        self.cursor.pos = self.cursor.pos + 1
    end
end

function console:execute(code)
    if self.command_arguments_input then
        if self:command_input(code) then
            self.command_arguments_input = false
        end
        return
    end
    local b, e
    for com, v in pairs(self.commands) do
        b, e = code:find(com, 0)
        if b then
            break
        end
    end
    if self.commands[code] then
        self.fast_command = false
        self.history[1].clr = color(1, 0, 1)
        self.history[1].str = '// ' .. self.history[1].str:sub(4, #self.history[1].str)
        self.commands[code](self)
        return
    elseif b == 1 and self.commands[code:sub(b or -1, e or -1)] then
        self.fast_command = true
        self.history[1].clr = color(1, 0, 1)
        self.history[1].str = '// ' .. self.history[1].str:sub(4, #self.history[1].str)
        self.commands[code:sub(b, e)](self)
        local args = code:sub(e+2, #code)
        self:execute(args)
        return
    end
    local chunk, error = load("return " .. code)
    if not chunk then
        chunk, error = load(code)
    end
    if chunk then
        local returned = { pcall(chunk) }
        if returned[1] then
            table.remove(returned, 1)
            for i, r in pairs(returned) do
                self:print({r})
            end
        else
            self:print({returned[2]})
        end
    else
        self:print({error}, color(1, 0, 0))
    end
end

function console:command_input(input)
    return true --ended
end

function console:draw()
    if self.opened then
        --background
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)
        --input line
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('fill', 0, HEIGHT-60, WIDTH, 2)
        --input txt
        love.graphics.setFont(self.style.font)
        local insy = love.graphics.getFont():getHeight(self.input)
        love.graphics.print(self.input, 20, HEIGHT-30-insy/2)
        --cursor
        local cpos = love.graphics.getFont():getWidth(self.input:sub(0, self.cursor.pos))
        love.graphics.setColor(self.cursor.color)
        love.graphics.rectangle('fill', 20+cpos, HEIGHT-30-insy/2, 2, insy)
        --optput
        for i, out in pairs(self.history) do
            love.graphics.setColor(out.clr)
            love.graphics.setFont(self.style.font)
            local outsy = love.graphics.getFont():getHeight(out.str)
            love.graphics.print(out.str, 20, HEIGHT-60-20-outsy*i)
        end
    end
end

return console