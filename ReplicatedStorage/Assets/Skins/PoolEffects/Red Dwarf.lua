return {
	name = "Red Dwarf",
	price = 100000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Red Dwarf" },
	colour = Color3.fromRGB(230, 90, 70),
	rarity = function(): string
		return "Tier5"
	end,
	chance = 5,
	labelTop = "Red Dwarf",
	labelBottom = "100000",
	image = "rbxassetid://129681645288321"
}