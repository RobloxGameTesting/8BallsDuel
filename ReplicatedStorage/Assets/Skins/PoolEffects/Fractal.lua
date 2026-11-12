return {
	name = "Fractal",
	price = 100000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Fractal" },
	colour = Color3.fromRGB(150, 200, 255),
	rarity = function(): string
		return "Tier5"
	end,
	chance = 5,
	labelTop = "Fractal",
	labelBottom = "100000",
	image = "rbxassetid://82800162480776"
}