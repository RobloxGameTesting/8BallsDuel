local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

return {
	id = script.Name,
	instance = script.Bullet,
	speed = { min = 200, max = 200 },
	distance = 400,
	damage = 80,
	knockback = { distance = 3, speed = 100 },
	pierce = true,
	ricochet = true,
	fragment = nil,
	explosive = nil
}