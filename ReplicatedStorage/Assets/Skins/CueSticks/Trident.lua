local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Trident",
	description = "",
	info = "Info",
	infoLink = "Exclusive item for hitting 2,500 likes!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Atlantis_Tier_3",
	cue = "Atlantis_Tier_3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Trident",
	labelBottom = "",
	image = ""
}