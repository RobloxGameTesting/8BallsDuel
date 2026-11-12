return {
	name = "Seer",
	price = 15000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Seer" },
	colour = Color3.fromRGB(140, 190, 240),
	rarity = function(): string
		return "Tier3"
	end,
	chance = 18,
	labelTop = "Seer",
	labelBottom = "15000",
	image = "rbxassetid://125542529726004"
}