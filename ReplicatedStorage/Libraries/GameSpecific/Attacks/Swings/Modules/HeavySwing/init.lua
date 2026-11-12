local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Swings.SwingTypes)

return {
	id = script.Name,
	damage = 50,
	duration = 0.7,
	delay = 0.1,
	knockback = { distance = 20, speed = 100 },
	pierce = true
}