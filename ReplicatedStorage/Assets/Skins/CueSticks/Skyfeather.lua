local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Skyfeather",
	description = "",
	info = "Info",
	infoLink = "Exclusive item for hitting 100 likes!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Skyfeather_Cue_Tier_3",
	cue = "Skyfeather_Cue_Tier_3",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Skyfeather",
	labelBottom = "",
	image = ""
}