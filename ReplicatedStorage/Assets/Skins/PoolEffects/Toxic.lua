return {
	name = "Toxic",
	price = 2000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Toxic" },
	colour = Color3.fromRGB(140, 230, 80),
	rarity = function(): string
		return "Tier1"
	end,
	chance = 40,
	labelTop = "Toxic",
	labelBottom = "2000",
	image = "rbxassetid://136048075503653"
}