local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

return {
	id = script.Name,
	instance = script.Bullet,
	speed = { min = 400, max = 500 },
	distance = 400,
	damage = 75,
	knockback = { distance = 3, speed = 100 },
	pierce = true,
	ricochet = false,
	fragment = nil,
	explosive = nil
}