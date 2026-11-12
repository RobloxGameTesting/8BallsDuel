local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Rainbow Prism",
	description = "",
	info = "Info",
	infoLink = "Unlock by getting lucky from a card flip!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Prism_Alloy_Tier_2",
	cue = "Prism_Alloy_Tier_2",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Rainbow Prism",
	labelBottom = "",
	image = ""
}