local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)

return {
	id = script.Name,
	instance = script.Bullet,
	speed = { min = 180, max = 200 },
	distance = 200,
	damage = 0,
	knockback = { distance = 0, speed = 100 },
	pierce = false,
	ricochet = false,
	fragment = nil,
	explosive = "Explosion150Damage"
}