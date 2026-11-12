local v = {
	Normal = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 90)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 230))
		}),
		effect = {},
		sound = "Tier1",
		percent = { Normal = 45, Premium = 0 }
	},
	Tier2 = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(21, 220, 34)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(71, 243, 100))
		}),
		effect = {},
		sound = "Tier2"
	},
	Tier3 = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 169, 241)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 110, 230))
		}),
		effect = {},
		sound = "Tier3"
	},
	Tier4 = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(114, 0, 208)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 0, 255))
		}),
		effect = {},
		sound = "Tier4"
	},
	Tier5 = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
		}),
		effect = {},
		sound = "Tier5"
	},
	Tier6 = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(221, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(136, 0, 0))
		}),
		effect = { "Rotation", "BossSparkles" },
		sound = "Tier6"
	},
	Tier7 = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 225, 0)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(149, 0, 0)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(62, 0, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(79, 0, 0)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(216, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 234, 0))
		}),
		effect = { "RotationSlow", "YellowSparkles" },
		sound = "Tier7"
	},
	TierBoss = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 225, 0))
		}),
		effect = { "Rotation", "BossSparkles" },
		sound = "TierBoss"
	},
	Golden = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(211, 164, 64)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(180, 127, 65)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(226, 190, 113)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(253, 251, 192)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(214, 176, 84)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(187, 126, 23))
		}),
		effect = { "RotationSlow", "YellowSparkles", "Shine" },
		sound = "TierBoss",
		percent = { Normal = 0.5, Premium = 5 }
	},
	TierRainbow = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 225, 0)),
			ColorSequenceKeypoint.new(0.332, Color3.fromRGB(17, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 253, 232)),
			ColorSequenceKeypoint.new(0.664, Color3.fromRGB(0, 38, 255)),
			ColorSequenceKeypoint.new(0.883, Color3.fromRGB(247, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		}),
		effect = { "RotationSlow", "YellowSparkles", "Shine" },
		sound = "TierBoss"
	},
	Common = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(98, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 255, 0))
		}),
		effect = {},
		sound = "Tier6",
		percent = { Normal = 45, Premium = 0 }
	},
	Rare = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 145, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 153, 255))
		}),
		effect = {},
		sound = "Tier6",
		percent = { Normal = 35, Premium = 40 }
	},
	Specialization = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 85, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 115, 0))
		}),
		effect = {},
		sound = "Tier6",
		percent = { Normal = 16, Premium = 35 }
	},
	Legendary = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		}),
		effect = {},
		sound = "Tier6",
		percent = { Normal = 3.5, Premium = 20 }
	},
	Insignia = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(119, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(102, 0, 255))
		}),
		effect = {},
		sound = "Tier6",
		percent = { Normal = 0.5, Premium = 5 }
	},
	TierSkip = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(114, 0, 208)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 0, 255))
		}),
		effect = { "Starburst", "BossSparkles" },
		sound = "Tier4"
	},
	Option = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(188, 188, 188)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(223, 223, 223))
		}),
		effect = {},
		sound = "Tier1"
	},
	Tier1 = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 90)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 230))
		}),
		effect = {},
		sound = "Tier1"
	},
	TierPremium = {
		colour = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(211, 164, 64)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(180, 127, 65)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(226, 190, 113)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(253, 251, 192)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(214, 176, 84)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(187, 126, 23))
		}),
		effect = { "YellowSparkles", "Shine" },
		sound = "TierBoss"
	}
}

local Rarities = {}

v.TierRobux = v.TierPremium

function Rarities.GetRarityData(p: string)
	return v[p]
end

return Rarities