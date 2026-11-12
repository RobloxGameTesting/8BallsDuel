return {
	name = "Golden",
	price = 0,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Golden" },
	colour = Color3.fromRGB(255, 205, 70),
	rarity = function(): string
		return "TierRobux"
	end,
	chance = 1,
	labelTop = "Golden",
	labelBottom = "Robux",
	image = "rbxassetid://130547503608715"
}