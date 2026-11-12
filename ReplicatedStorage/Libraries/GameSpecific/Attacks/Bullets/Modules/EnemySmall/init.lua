local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

return {
	id = script.Name,
	instance = script.Bullet,
	speed = { min = 30, max = 30 },
	distance = 400,
	damage = 1,
	knockback = { distance = 1, speed = 100 },
	pierce = false,
	ricochet = false,
	fragment = nil,
	explosive = nil
}