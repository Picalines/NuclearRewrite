local machinegun = class(EntityClasses.pistol)

machinegun.type_id = 'machinegun'

function machinegun:on_spawn(...)
    self.__parent.on_spawn(self, ...)

    self.ammo = {
        maxtotal  = 500,
        total     = 490,
        maxholder = 10,
        holder    = 10
    }

    self.shooting.speed  = 0.15
    self.reloading.speed = 0.2

    self.sprite = Assets.entities.machinegun
    self.auto   = true

    self.projectile = 'bullet'

    self:setInfo{
        name           = "machinegun",
        description    = "not realy classic...",
        ammo_bar_color = EntityClasses.bullet.color
    }

end

return machinegun