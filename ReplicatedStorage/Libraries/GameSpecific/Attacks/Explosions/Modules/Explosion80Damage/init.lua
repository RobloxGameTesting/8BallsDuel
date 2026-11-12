local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions.ExplosionTypes)

return {
	id = script.Name,
	damage = 80,
	duration = 0.1,
	radius = 20,
	knockback = { distance = 20, speed = 100 }
}