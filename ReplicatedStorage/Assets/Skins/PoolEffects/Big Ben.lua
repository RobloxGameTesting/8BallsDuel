return {
	name = "Big Ben",
	price = 6000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Big Ben" },
	colour = Color3.fromRGB(220, 190, 120),
	rarity = function(): string
		return "Tier2"
	end,
	chance = 25,
	labelTop = "Big Ben",
	labelBottom = "6000",
	image = "rbxassetid://102367587138298"
}