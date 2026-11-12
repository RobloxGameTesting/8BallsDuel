local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Throwables.ThrowableTypes)

return {
	id = script.Name,
	instance = script.Object,
	speed = 100,
	distance = 200,
	damage = 34,
	knockback = { distance = 3, speed = 100 },
	pierce = false,
	ricochet = false,
	fragment = nil,
	explosive = "Splash Health Potion",
	timeNeeded = 2,
	dampenRate = 1.8
}