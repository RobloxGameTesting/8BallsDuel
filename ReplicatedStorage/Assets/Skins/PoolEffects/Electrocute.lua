return {
	name = "Electrocute",
	price = 250000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Electrocute" },
	colour = Color3.fromRGB(120, 220, 255),
	rarity = function(): string
		return "Tier6"
	end,
	chance = 2,
	labelTop = "Electrocute",
	labelBottom = "250000",
	image = "rbxassetid://80266363246294"
}