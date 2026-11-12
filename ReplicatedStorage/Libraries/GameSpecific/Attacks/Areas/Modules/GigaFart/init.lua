local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Areas.AreaTypes)

return {
	id = script.Name,
	damage = 300,
	duration = 0.1,
	knockback = { distance = 20, speed = 150 }
}