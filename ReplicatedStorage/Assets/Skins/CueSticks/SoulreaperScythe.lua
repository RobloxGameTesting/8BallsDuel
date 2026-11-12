local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

return {
	name = "Soulreaper Scythe",
	description = "",
	info = "Info",
	infoLink = "Unlocked from the Spooky Season battlepass!",
	itemType = "CueStick",
	modelFolder = { "Sticks" },
	modelName = "Soulreaper_Scythe_T5",
	cue = "Soulreaper_Scythe_T5",
	rarity = function(): string
		return "Tier4"
	end,
	chance = 1,
	labelTop = "Soulreaper Scythe",
	labelBottom = "",
	image = ""
}