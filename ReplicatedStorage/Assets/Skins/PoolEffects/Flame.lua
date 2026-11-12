return {
	name = "Flame",
	price = 6000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Flame" },
	colour = Color3.fromRGB(255, 140, 60),
	rarity = function(): string
		return "Tier2"
	end,
	chance = 25,
	labelTop = "Flame",
	labelBottom = "6000",
	image = "rbxassetid://74143911027725"
}