return {
	name = "Radioactive",
	price = 15000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Radioactive" },
	colour = Color3.fromRGB(150, 240, 70),
	rarity = function(): string
		return "Tier3"
	end,
	chance = 18,
	labelTop = "Radioactive",
	labelBottom = "15000",
	image = "rbxassetid://73465250746482"
}