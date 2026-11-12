local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities.AbilityTypes)

return {
	id = script.Name,
	duration = 0,
	requirements = function(): boolean
		return true
	end
}