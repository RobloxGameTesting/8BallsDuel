return {
	name = "Black Hole",
	price = 100000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Black Hole" },
	colour = Color3.fromRGB(120, 90, 190),
	rarity = function(): string
		return "Tier5"
	end,
	chance = 5,
	labelTop = "Black Hole",
	labelBottom = "100000",
	image = "rbxassetid://124497661898388"
}