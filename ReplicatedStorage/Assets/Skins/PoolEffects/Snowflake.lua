return {
	name = "Snowflake",
	price = 100000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Snowflake" },
	colour = Color3.fromRGB(190, 235, 255),
	rarity = function(): string
		return "Tier5"
	end,
	chance = 5,
	labelTop = "Snowflake",
	labelBottom = "100000",
	image = "rbxassetid://134316997170276"
}