return {
	activeAbility = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(126, 247, 222)),
		ColorSequenceKeypoint.new(0.99, Color3.fromRGB(0, 169, 242)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	}),
	passiveAbility = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(242, 147, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(241, 90, 36))
	}),
	black = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 23, 34)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	}),
	blackEquipped = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 23, 34)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 42, 32))
	}),
	selected = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(242, 147, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(241, 90, 36))
	}),
	deselected = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 240, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 190))
	}),
	quest = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(126, 247, 222)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 169, 242))
	}),
	questComplete = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(251, 255, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 242, 0))
	}),
	goldPass = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(241, 213, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 234, 0))
	}),
	err = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 36, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(181, 22, 36))
	}),
	eventCurrency = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 110, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 179, 255))
	}),
	expBoost = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(126, 247, 242)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 169, 242))
	}),
	openBoost = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(251, 255, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 242, 0))
	}),
	Tier1 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 220, 170)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(181, 160, 119))
	}),
	Tier2 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 191, 132)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 147, 80))
	}),
	Tier3 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 216, 76)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 204, 0))
	}),
	Tier4 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 132, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 106, 0))
	}),
	Tier5 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(162, 0, 0))
	}),
	TierRobux = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(211, 164, 64)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(180, 127, 65)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(226, 190, 113)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(253, 251, 192)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(214, 176, 84)),
		ColorSequenceKeypoint.new(0.99, Color3.fromRGB(187, 126, 23)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	}),
	Ascended = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 36, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(181, 22, 36))
	}),
	Soaring = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 128, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(177, 89, 0))
	}),
	Professional = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 234, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(234, 183, 0))
	}),
	["Shoyo Hinata"] = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 128, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(227, 28, 48))
	}),
	Emotes = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 252, 126)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 199, 100))
	}),
	Balls = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 252, 126)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 199, 100))
	}),
	ScoreVFX = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 252, 126)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 199, 100))
	})
}