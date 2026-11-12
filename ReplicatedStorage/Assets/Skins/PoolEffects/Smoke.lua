return {
	name = "Smoke",
	price = 2000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Smoke" },
	colour = Color3.fromRGB(170, 170, 175),
	rarity = function(): string
		return "Tier1"
	end,
	chance = 40,
	labelTop = "Smoke",
	labelBottom = "2000",
	image = "rbxassetid://97075893866172"
}