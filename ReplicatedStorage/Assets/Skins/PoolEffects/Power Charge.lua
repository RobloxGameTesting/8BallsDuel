return {
	name = "Power Charge",
	price = 6000,
	itemType = "PoolEffect",
	vfxPath = { "ScoreVFX", "Power Charge" },
	colour = Color3.fromRGB(255, 220, 100),
	rarity = function(): string
		return "Tier2"
	end,
	chance = 25,
	labelTop = "Power Charge",
	labelBottom = "6000",
	image = "rbxassetid://84154678031272"
}