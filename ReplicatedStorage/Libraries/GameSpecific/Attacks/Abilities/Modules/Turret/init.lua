local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities.AbilityTypes)

return {
	id = script.Name,
	duration = 100,
	requirements = function(): boolean
		return true
	end,
	price = 100,
	rarity = "Common",
	labelTop = "Anti-Zombie",
	labelBottom = "Turret",
	image = "",
	mastery = "Heavy"
}