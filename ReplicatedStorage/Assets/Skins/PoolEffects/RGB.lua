return {
	name = "RGB",
	price = 100000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "RGB" },
	colour = Color3.fromRGB(255, 255, 255),
	rarity = function(): string
		return "Tier5"
	end,
	chance = 5,
	labelTop = "RGB",
	labelBottom = "100000",
	image = "rbxassetid://96209754663455"
}