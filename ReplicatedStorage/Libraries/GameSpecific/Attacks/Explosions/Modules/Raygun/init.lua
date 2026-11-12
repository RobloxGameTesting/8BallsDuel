local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions.ExplosionTypes)

return {
	id = script.Name,
	damage = 110,
	duration = 0.1,
	radius = 20,
	knockback = { distance = 8, speed = 100 }
}