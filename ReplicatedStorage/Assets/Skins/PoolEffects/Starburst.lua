return {
	name = "Starburst",
	price = 100000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Starburst" },
	colour = Color3.fromRGB(255, 240, 180),
	rarity = function(): string
		return "Tier5"
	end,
	chance = 5,
	labelTop = "Starburst",
	labelBottom = "100000",
	image = "rbxassetid://109577658487864"
}