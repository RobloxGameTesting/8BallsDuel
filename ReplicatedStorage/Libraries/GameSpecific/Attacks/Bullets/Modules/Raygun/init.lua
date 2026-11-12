local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

return {
	id = script.Name,
	instance = script.Bullet,
	speed = { min = 300, max = 300 },
	distance = 100,
	damage = 0,
	knockback = { distance = 0, speed = 0 },
	pierce = false,
	ricochet = false,
	fragment = nil,
	explosive = "Raygun"
}