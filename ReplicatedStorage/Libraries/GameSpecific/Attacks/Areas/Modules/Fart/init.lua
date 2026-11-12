local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Areas.AreaTypes)

return {
	id = script.Name,
	damage = 150,
	duration = 0.1,
	knockback = { distance = 10, speed = 100 }
}