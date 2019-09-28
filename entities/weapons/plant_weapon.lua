local plant_weapon = class(EntityClasses.pistol)

plant_weapon.type_id = 'plant_weapon'

function plant_weapon:on_spawn(...)
    self.__parent.on_spawn(self, ...)
    self.sprite = Assets.entities.plant_pistol
    self.projectile = 'seed_bullet'
    self.shooting.speed = 1
end

return plant_weapon