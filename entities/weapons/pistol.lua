local pistol = class(Weapon)

pistol.type_id = 'pistol'

function pistol:on_spawn(room, pos)
    self.room = room
    self.pos = pos
    self.sound = Assets.sfx.pistol

    self.hitbox.sx, self.hitbox.sy = 10, 6

    self.ammo.maxtotal  = nil
    self.ammo.total     = nil
    self.ammo.holder    = 5
    self.ammo.maxholder = 5

    self.projectile = 'lazer_bullet'

    self.sprite = Assets.entities.pistol

    self:setInfo{
        name           = "spaceman's pistol",
        description    = "classic...",
        ammo_bar_color = EntityClasses.lazer_bullet.color
    }

end

function pistol:on_shoot()
    self.hand_ofset = 3
    self.sound:play()
end

return pistol