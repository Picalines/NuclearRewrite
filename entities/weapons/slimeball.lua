local slimeball_weap = class(Weapon)

slimeball_weap.type_id = 'slimeball_weap'

function slimeball_weap:on_spawn(room, pos, ...)
    self.room = room
    self.pos  = pos
    
end

function slimeball_weap:update(dt)

end

function slimeball_weap:draw()

end

return slimeball_weap