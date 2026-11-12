local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

return {
	id = script.Name,
	instance = script.Bullet,
	speed = { min = 400, max = 500 },
	distance = 200,
	damage = 120,
	knockback = { distance = 3, speed = 100 },
	pierce = false,
	ricochet = false,
	fragment = nil,
	explosive = nil
}