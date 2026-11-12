local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Arctic Breath",
	description = "Soul of the arctic cue breaker.",
	info = "Info",
	infoLink = "Unlock by getting lucky from a card flip!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Arctic_Flow_Tier_2",
	cue = "Arctic_Flow_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Arctic Breath",
	labelBottom = "120 Gems",
	image = ""
}