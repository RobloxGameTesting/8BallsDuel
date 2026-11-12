local closes = {
	"OfflineReward",
	"Admin",
	"Crafting",
	"Dialog",
	"Enchanting",
	"Inventory",
	"PackOpen",
	"Potions",
	"Sell",
	"StarterPackPrompt"
}
local closes2 = { "Achievements", "Backpack", "Quests", "Settings", "Store" }

return {
	OfflineReward = { exclusive = false, closes = closes },
	SkillTree = { exclusive = true },
	Achievements = { exclusive = false, closes = closes2 },
	Admin = { exclusive = false, closes = closes },
	Backpack = { exclusive = false, closes = closes2 },
	Crafting = { exclusive = false, closes = closes },
	Dialog = { exclusive = false, closes = closes },
	Enchanting = { exclusive = false, closes = closes },
	Gift = { exclusive = false },
	Inventory = { exclusive = false, closes = closes },
	PackOpen = { exclusive = true },
	Potions = { exclusive = false, closes = closes },
	Quests = { exclusive = false, closes = closes2 },
	Sell = { exclusive = false },
	Settings = { exclusive = false, closes = closes2 },
	StarterPackPrompt = { exclusive = false, closes = closes },
	Store = { exclusive = false, closes = closes2 }
}