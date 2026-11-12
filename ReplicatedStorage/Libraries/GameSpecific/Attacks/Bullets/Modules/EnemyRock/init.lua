local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

return {
	id = script.Name,
	instance = script.Bullet,
	speed = { min = 150, max = 150 },
	distance = 400,
	damage = 40,
	knockback = { distance = 3, speed = 100 },
	pierce = false,
	ricochet = false,
	fragment = nil,
	explosive = nil
}