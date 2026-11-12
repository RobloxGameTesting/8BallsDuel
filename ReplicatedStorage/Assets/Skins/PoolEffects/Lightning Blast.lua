return {
	name = "Lightning Blast",
	price = 100000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Lightning Blast" },
	colour = Color3.fromRGB(160, 200, 255),
	rarity = function(): string
		return "Tier5"
	end,
	chance = 5,
	labelTop = "Lightning Blast",
	labelBottom = "100000",
	image = "rbxassetid://124161787710099"
}