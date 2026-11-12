return {
	name = "Headshot",
	price = 15000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Headshot" },
	colour = Color3.fromRGB(240, 80, 80),
	rarity = function(): string
		return "Tier3"
	end,
	chance = 18,
	labelTop = "Headshot",
	labelBottom = "15000",
	image = "rbxassetid://131797348314638"
}