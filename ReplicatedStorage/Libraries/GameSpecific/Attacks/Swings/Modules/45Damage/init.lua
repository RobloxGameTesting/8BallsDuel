local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Swings.SwingTypes)

return {
	id = script.Name,
	damage = 45,
	duration = 0.7,
	delay = 0.1,
	knockback = { distance = 8, speed = 100 },
	pierce = true
}