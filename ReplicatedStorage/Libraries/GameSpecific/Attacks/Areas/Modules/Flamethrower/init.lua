local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Areas.AreaTypes)

return {
	id = script.Name,
	damage = 35,
	duration = 0.1,
	knockback = { distance = 0, speed = 100 }
}