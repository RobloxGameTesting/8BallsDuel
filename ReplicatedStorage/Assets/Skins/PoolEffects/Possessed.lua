return {
	name = "Possessed",
	price = 15000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Possessed" },
	colour = Color3.fromRGB(150, 90, 180),
	rarity = function(): string
		return "Tier3"
	end,
	chance = 18,
	labelTop = "Possessed",
	labelBottom = "15000",
	image = "rbxassetid://87559579164249"
}