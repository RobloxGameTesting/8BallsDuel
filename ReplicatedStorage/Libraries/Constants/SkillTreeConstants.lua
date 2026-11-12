local v = {
	["Unlocked"] = Color3.fromRGB(76, 109, 255),
	CanAfford = Color3.fromRGB(70, 70, 70),
	CantAfford = Color3.fromRGB(70, 70, 70),
	Locked = Color3.fromRGB(35, 35, 45),
	Gamepass = Color3.fromRGB(81, 255, 0),
	Menu = Color3.fromRGB(255, 225, 0)
}

return {
	SKILL_TREES = {
		Main = {
			Rewards = {
				name = "Rewards",
				description = "Upgrade the rewards skill tree",
				icon = "rbxassetid://17009565402",
				cost = 0,
				position = Vector2.new(1, -1),
				requires = {},
				buttonType = "Menu"
			},
			["1856020514"] = {
				name = "V.I.P.",
				description = "Unlock: 1. 2. 3.",
				icon = "rbxassetid://17009565402",
				cost = 0,
				position = Vector2.new(0, 1),
				requires = {},
				buttonType = "Gamepass"
			},
			Innocent1 = {
				name = "Innocent Player I",
				description = "Spawns in one innocent player",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(0, 0),
				requires = {},
				buttonType = "Button"
			},
			Autoroll = {
				name = "Auto Open",
				description = "Auto opens the selected mystery box",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(1, 0),
				requires = {},
				buttonType = "Button"
			},
			CloverChance1 = {
				name = "Clover Chance I",
				description = "Increases the clover chance by 10%",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(2, -1),
				requires = { "Autoroll" },
				buttonType = "Button"
			},
			CloverChance2 = {
				name = "Clover Chance II",
				description = "Increases the clover chance by 20%",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(3, -2),
				requires = { "CloverChance1" },
				buttonType = "Button"
			},
			CloverChance3 = {
				name = "Clover Chance III",
				description = "Increases the clover chance by 30%",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(4, -3),
				requires = { "CloverChance2" },
				buttonType = "Button"
			},
			CloverChance4 = {
				name = "Clover Chance IV",
				description = "Increases the clover chance by 40%",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(5, -4),
				requires = { "CloverChance3" },
				buttonType = "Button"
			},
			Trading = {
				name = "Trading",
				description = "Allows you to trade knives and guns with other players!",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(4, -4),
				requires = { "CloverChance3" },
				buttonType = "Button"
			},
			FasterRoll1 = {
				name = "Faster Open I",
				description = "Mystery boxes open 0.5s faster",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(3, -1),
				requires = { "CloverChance1" },
				buttonType = "Button"
			},
			FasterRoll2 = {
				name = "Faster Open II",
				description = "Mystery boxes open 1s faster",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(4, -1),
				requires = { "FasterRoll1" },
				buttonType = "Button"
			},
			FasterRoll3 = {
				name = "Faster Open III",
				description = "Mystery boxes open 1.5s faster",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(5, -2),
				requires = { "FasterRoll2" },
				buttonType = "Button"
			},
			FasterRoll4 = {
				name = "Faster Open IV",
				description = "Mystery boxes open 2s faster",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(6, -3),
				requires = { "FasterRoll3" },
				buttonType = "Button"
			},
			FasterRoll5 = {
				name = "Faster Open V",
				description = "Mystery boxes open 2.5s faster",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(7, -4),
				requires = { "FasterRoll4" },
				buttonType = "Button"
			},
			RollAmount1 = {
				name = "2 Opens",
				description = "Open 2 mystery boxes instead of 1",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(5, -1),
				requires = { "FasterRoll2" },
				buttonType = "Button"
			},
			RollAmount2 = {
				name = "3 Opens",
				description = "Open 3 mystery boxes instead of 1",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(6, -1),
				requires = { "RollAmount1" },
				buttonType = "Button"
			},
			RollAmount3 = {
				name = "4 Opens",
				description = "Open 4 mystery boxes instead of 1",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(7, -1),
				requires = { "RollAmount2" },
				buttonType = "Button"
			},
			RollAmount4 = {
				name = "5 Opens",
				description = "Open 5 mystery boxes instead of 1",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(7, 0),
				requires = { "RollAmount3" },
				buttonType = "Button"
			},
			RollAmount5 = {
				name = "6 Opens",
				description = "Open 6 mystery boxes instead of 2",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(8, 0),
				requires = { "RollAmount4" },
				buttonType = "Button"
			},
			Luck1 = {
				name = "Luck I",
				description = "Gives a +50% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(1, 1),
				requires = { "Autoroll" },
				buttonType = "Button"
			},
			Luck2 = {
				name = "Luck II",
				description = "Gives a +100% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(2, 1),
				requires = { "Luck1" },
				buttonType = "Button"
			},
			Luck3 = {
				name = "Luck III",
				description = "Gives a +150% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(3, 1),
				requires = { "Luck2" },
				buttonType = "Button"
			},
			Luck4 = {
				name = "Extra Luck I",
				description = "Gives a +200% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(4, 1),
				requires = { "Luck3" },
				buttonType = "Button"
			},
			Luck5 = {
				name = "Extra Luck II",
				description = "Gives a +250% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(5, 1),
				requires = { "Luck4" },
				buttonType = "Button"
			},
			Luck6 = {
				name = "Extra Luck III",
				description = "Gives a +300% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(5, 2),
				requires = { "Luck5" },
				buttonType = "Button"
			},
			Luck7 = {
				name = "Super Luck I",
				description = "Gives a +350% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(6, 2),
				requires = { "Luck6" },
				buttonType = "Button"
			},
			Luck8 = {
				name = "Super Luck II",
				description = "Gives a +400% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(7, 2),
				requires = { "Luck7" },
				buttonType = "Button"
			},
			Luck9 = {
				name = "Super Luck III",
				description = "Gives a +450% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(7, 3),
				requires = { "Luck8" },
				buttonType = "Button"
			},
			Luck10 = {
				name = "ULTRA LUCK",
				description = "Gives a +500% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 100000,
				position = Vector2.new(8, 3),
				requires = { "Luck9" },
				buttonType = "Button"
			},
			FriendLuck1 = {
				name = "Friend Luck I",
				description = "Playing with a friend gives a +100% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(3, 2),
				requires = { "Luck3" },
				buttonType = "Button"
			},
			FriendLuck2 = {
				name = "Friend Luck II",
				description = "Playing with 2 friends gives a +200% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(3, 3),
				requires = { "FriendLuck1" },
				buttonType = "Button"
			},
			FriendLuck3 = {
				name = "Friend Luck III",
				description = "Playing with 3 friends gives a +300% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(3, 4),
				requires = { "FriendLuck2" },
				buttonType = "Button"
			},
			FriendLuck4 = {
				name = "Friend Luck IV",
				description = "Playing with 4 friends gives a +400% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(3, 5),
				requires = { "FriendLuck3" },
				buttonType = "Button"
			},
			FriendLuck5 = {
				name = "Friend Luck V",
				description = "Playing with 5 friends gives a +500% luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(3, 6),
				requires = { "FriendLuck4" },
				buttonType = "Button"
			},
			FriendMoney1 = {
				name = "Friend Money I",
				description = "Playing with 1 friend gives +10% money when selling items",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(4, 4),
				requires = { "FriendLuck3" },
				buttonType = "Button"
			},
			FriendMoney2 = {
				name = "Friend Money II",
				description = "Playing with 1 friend gives +20% money when selling items",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(5, 4),
				requires = { "FriendMoney1" },
				buttonType = "Button"
			},
			FriendMoney3 = {
				name = "Friend Money III",
				description = "Playing with 1 friend gives +30% money when selling items",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(5, 5),
				requires = { "FriendMoney2" },
				buttonType = "Button"
			},
			FriendMoney4 = {
				name = "Friend Money IV",
				description = "Playing with 1 friend gives +40% money when selling items",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(6, 5),
				requires = { "FriendMoney3" },
				buttonType = "Button"
			},
			FriendMoney5 = {
				name = "Friend Money V",
				description = "Playing with 1 friend gives +50% money when selling items",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(7, 5),
				requires = { "FriendMoney4" },
				buttonType = "Button"
			},
			GoldSpin1 = {
				name = "Gold Unbox",
				description = "Every 10th mystery box has a 2x luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(1, 2),
				requires = { "Luck1" },
				buttonType = "Button"
			},
			GoldSpin2 = {
				name = "Gold Boost I",
				description = "Every 9th mystery box is a Gold Unbox",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(1, 3),
				requires = { "GoldSpin1" },
				buttonType = "Button"
			},
			GoldSpin3 = {
				name = "Gold Boost II",
				description = "Every 8th mystery box is a Gold Unbox",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(1, 4),
				requires = { "GoldSpin2" },
				buttonType = "Button"
			},
			GoldSpin4 = {
				name = "Gold Boost III",
				description = "Every 7th mystery box is a Gold Unbox",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(1, 5),
				requires = { "GoldSpin3" },
				buttonType = "Button"
			},
			DiamondSpin1 = {
				name = "Diamond Unbox",
				description = "Every 50th mystery box has an 8x luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(0, 4),
				requires = { "GoldSpin2" },
				buttonType = "Button"
			},
			DiamondSpin2 = {
				name = "Diamond Boost I",
				description = "Every 45th mystery box is a Diamond Unbox",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(-1, 5),
				requires = { "DiamondSpin1" },
				buttonType = "Button"
			},
			DiamondSpin3 = {
				name = "Diamond Boost II",
				description = "Every 40th mystery box is a Diamond Unbox",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(-2, 6),
				requires = { "DiamondSpin2" },
				buttonType = "Button"
			},
			DiamondSpin4 = {
				name = "Diamond Boost III",
				description = "Every 35th mystery box is a Diamond Unbox",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(-3, 7),
				requires = { "DiamondSpin3" },
				buttonType = "Button"
			},
			VoidSpin1 = {
				name = "Void Unbox",
				description = "Every 500th mystery box has a 50x luck boost",
				icon = "rbxassetid://17009565402",
				cost = 10000,
				position = Vector2.new(-2, 5),
				requires = { "DiamondSpin2" },
				buttonType = "Button"
			},
			Innocent2 = {
				name = "Innocent Player II",
				description = "Spawns in two innocent players",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-1, 1),
				requires = { "Innocent1" },
				buttonType = "Button"
			},
			Innocent3 = {
				name = "Innocent Player III",
				description = "Spawns in three innocent players",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-2, 2),
				requires = { "Innocent2" },
				buttonType = "Button"
			},
			Innocent4 = {
				name = "Innocent Player IV",
				description = "Spawns in four innocent players",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-3, 3),
				requires = { "Innocent3" },
				buttonType = "Button"
			},
			Innocent5 = {
				name = "Innocent Player V",
				description = "Spawns in five innocent players",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-4, 4),
				requires = { "Innocent4" },
				buttonType = "Button"
			},
			Innocent6 = {
				name = "Innocent Player VI",
				description = "Spawns in six innocent players",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-5, 5),
				requires = { "Innocent5" },
				buttonType = "Button"
			},
			Innocent7 = {
				name = "Innocent Player VII",
				description = "Spawns in seven innocent players",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-6, 5),
				requires = { "Innocent6" },
				buttonType = "Button"
			},
			FriendInnocent = {
				name = "Murder Friends",
				description = "Innocent players have a chance of being your friend. They give 5x kill points",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-4, 3),
				requires = { "Innocent4" },
				buttonType = "Button"
			},
			FamousInnocent = {
				name = "Murder Celebrities",
				description = "Innocent players have a chance of being a famous player! They give 50x kill points",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-5, 3),
				requires = { "FriendInnocent" },
				buttonType = "Button"
			},
			Autoattack = {
				name = "Auto Attack",
				description = "Auto attacks innocents for you!",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-2, 1),
				requires = { "Innocent2" },
				buttonType = "Button"
			},
			AttackRange1 = {
				name = "Attack Range I",
				description = "Your auto attack can detect enemies that are +5 studs further away",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-3, 1),
				requires = { "Autoattack" },
				buttonType = "Button"
			},
			AttackRange2 = {
				name = "Attack Range II",
				description = "Your auto attack can detect enemies that are +10 studs further away",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-4, 1),
				requires = { "AttackRange1" },
				buttonType = "Button"
			},
			AttackRange3 = {
				name = "Attack Range III",
				description = "Your auto attack can detect enemies that are +15 studs further away",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-4, 0),
				requires = { "AttackRange2" },
				buttonType = "Button"
			},
			AttackRange4 = {
				name = "Attack Range IV",
				description = "Your auto attack can detect enemies that are +20 studs further away",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-5, 0),
				requires = { "AttackRange3" },
				buttonType = "Button"
			},
			SpawnRate1 = {
				name = "Spawn Rate I",
				description = "Respawns innocents faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-1, 2),
				requires = { "Innocent2" },
				buttonType = "Button"
			},
			SpawnRate2 = {
				name = "Spawn Rate II",
				description = "Respawns innocents faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-1, 3),
				requires = { "SpawnRate1" },
				buttonType = "Button"
			},
			SpawnRate3 = {
				name = "Spawn Rate III",
				description = "Respawns innocents faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-2, 4),
				requires = { "SpawnRate2" },
				buttonType = "Button"
			},
			SpawnRate4 = {
				name = "Spawn Rate IV",
				description = "Respawns innocents faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-3, 5),
				requires = { "SpawnRate3" },
				buttonType = "Button"
			},
			DamageMultiplier1 = {
				name = "Damage Boost I",
				description = "Deal 10% more damage",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(0, -1),
				requires = { "Innocent1" },
				buttonType = "Button"
			},
			DamageMultiplier2 = {
				name = "Damage Boost II",
				description = "Deal 20% more damage",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-1, -1),
				requires = { "DamageMultiplier1" },
				buttonType = "Button"
			},
			DamageMultiplier3 = {
				name = "Damage Boost III",
				description = "Deal 30% more damage",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-2, -1),
				requires = { "DamageMultiplier2" },
				buttonType = "Button"
			},
			DamageMultiplier4 = {
				name = "Damage Boost IV",
				description = "Deal 40% more damage",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-2, -2),
				requires = { "DamageMultiplier3" },
				buttonType = "Button"
			},
			DamageMultiplier5 = {
				name = "Damage Boost V",
				description = "Deal 50% more damage",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-3, -2),
				requires = { "DamageMultiplier4" },
				buttonType = "Button"
			},
			FireDamage1 = {
				name = "Fire Damage",
				description = "Has a chance of setting the innocent on fire",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-3, -3),
				requires = { "DamageMultiplier5" },
				buttonType = "Button"
			},
			PoisonDamage1 = {
				name = "Poison Damage",
				description = "Has a chance of poisoning the innocent",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-3, -4),
				requires = { "FireDamage1" },
				buttonType = "Button"
			},
			ElectricDamage1 = {
				name = "Electric Damage",
				description = "Has a chance of electrocuting the innocent",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(-2, -4),
				requires = { "FireDamage1" },
				buttonType = "Button"
			},
			AttackSpeed1 = {
				name = "Attack Speed I",
				description = "Allows you to attack faster. Gun reloads faster, knife throws faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(0, -2),
				requires = { "DamageMultiplier1" },
				buttonType = "Button"
			},
			AttackSpeed2 = {
				name = "Attack Speed II",
				description = "Allows you to attack faster. Gun reloads faster, knife throws faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(0, -3),
				requires = { "AttackSpeed1" },
				buttonType = "Button"
			},
			AttackSpeed3 = {
				name = "Attack Speed III",
				description = "Allows you to attack faster. Gun reloads faster, knife throws faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(0, -4),
				requires = { "AttackSpeed2" },
				buttonType = "Button"
			},
			AttackSpeed4 = {
				name = "Attack Speed IV",
				description = "Allows you to attack faster. Gun reloads faster, knife throws faster",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(0, -5),
				requires = { "AttackSpeed3" },
				buttonType = "Button"
			}
		},
		Rewards = {
			Main = {
				name = "Back",
				description = "Spawns in one innocent player",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(0, 0),
				requires = {},
				buttonType = "Menu"
			},
			CoinDrops1 = {
				name = "Coin Drops I",
				description = "Innocents now drop coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-1, 0),
				requires = {},
				buttonType = "Button"
			},
			CoinDrops2 = {
				name = "Coin Drops II",
				description = "Innocents now drop coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-1, -1),
				requires = { "CoinDrops1" },
				buttonType = "Button"
			},
			CoinDrops3 = {
				name = "Coin Drops III",
				description = "Innocents now drop coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-1, -2),
				requires = { "CoinDrops2" },
				buttonType = "Button"
			},
			CoinDrops4 = {
				name = "Coin Drops IV",
				description = "Innocents now drop coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(0, -3),
				requires = { "CoinDrops3" },
				buttonType = "Button"
			},
			CoinDrops5 = {
				name = "Coin Drops V",
				description = "Innocents now drop coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(1, -4),
				requires = { "CoinDrops4" },
				buttonType = "Button"
			},
			CoinDrops6 = {
				name = "Coin Drops VI",
				description = "Innocents now drop coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(1, -5),
				requires = { "CoinDrops5" },
				buttonType = "Button"
			},
			CoinDrops7 = {
				name = "Coin Drops VII",
				description = "Innocents now drop coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(0, -5),
				requires = { "CoinDrops6" },
				buttonType = "Button"
			},
			InstaKill1 = {
				name = "Insta Killer I",
				description = "One hitting an innocent drops 50% more coins",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-2, -2),
				requires = { "CoinDrops3" },
				buttonType = "Button"
			},
			Killpoints1 = {
				name = "Kill Point Multi I",
				description = "Doubles kill points!",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(1, -1),
				requires = {},
				buttonType = "Button"
			},
			Killpoints2 = {
				name = "Kill Point Multi II",
				description = "Doubles kill points!",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(1, -2),
				requires = { "Killpoints1" },
				buttonType = "Button"
			},
			Killpoints3 = {
				name = "Kill Point Multi III",
				description = "Doubles kill points!",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(2, -3),
				requires = { "Killpoints2" },
				buttonType = "Button"
			},
			Killpoints4 = {
				name = "Kill Point Multi IV",
				description = "Doubles kill points!",
				icon = "rbxassetid://17009565402",
				cost = 100,
				position = Vector2.new(3, -4),
				requires = { "Killpoints3" },
				buttonType = "Button"
			},
			DropLuck1 = {
				name = "Luck Potion",
				description = "Innocents have a chance of dropping a Luck Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(0, 1),
				requires = {},
				buttonType = "Button"
			},
			DropLuck2 = {
				name = "Luck Potion",
				description = "Innocents have a chance of dropping an Extra Luck Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-1, 2),
				requires = { "DropLuck1" },
				buttonType = "Button"
			},
			DropLuck3 = {
				name = "Luck Potion",
				description = "Innocents have a chance of dropping a Super Luck Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-2, 3),
				requires = { "DropLuck2" },
				buttonType = "Button"
			},
			DropCurrency1 = {
				name = "Coin Potion",
				description = "Innocents have a chance of dropping a Coin Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(1, 1),
				requires = { "DropLuck1" },
				buttonType = "Button"
			},
			DropMurder1 = {
				name = "Murder Potion",
				description = "Innocents have a chance of dropping a Murder Point Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(1, 2),
				requires = { "DropCurrency1" },
				buttonType = "Button"
			},
			DropClover1 = {
				name = "2x Clover Potion",
				description = "Innocents have a chance of dropping a 2x Clover Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(2, 0),
				requires = { "DropCurrency1" },
				buttonType = "Button"
			},
			DropClover2 = {
				name = "4x Clover Potion",
				description = "Innocents have a chance of dropping a 4x Clover Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(3, -1),
				requires = { "DropClover1" },
				buttonType = "Button"
			},
			DropClover3 = {
				name = "8x Clover Potion",
				description = "Innocents have a chance of dropping a 8x Clover Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(3, -2),
				requires = { "DropClover2" },
				buttonType = "Button"
			},
			DropClover4 = {
				name = "16x Clover Potion",
				description = "Innocents have a chance of dropping a 16x Clover Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(4, -3),
				requires = { "DropClover3" },
				buttonType = "Button"
			},
			DropClover5 = {
				name = "32x Clover Potion",
				description = "Innocents have a chance of dropping a 32x Clover Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(5, -3),
				requires = { "DropClover4" },
				buttonType = "Button"
			},
			DropClover6 = {
				name = "64x Clover Potion",
				description = "Innocents have a chance of dropping a 64x Clover Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(5, -2),
				requires = { "DropClover5" },
				buttonType = "Button"
			},
			DropClover7 = {
				name = "128x Clover Potion",
				description = "Innocents have a chance of dropping a 128x Clover Potion",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(5, -1),
				requires = { "DropClover6" },
				buttonType = "Button"
			},
			OfflineRewards1 = {
				name = "Offline Earnings I",
				description = "Get 10% more offline earnings",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-2, 1),
				requires = {},
				buttonType = "Button"
			},
			OfflineRewards2 = {
				name = "Offline Earnings II",
				description = "Get 20% more offline earnings",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-3, 2),
				requires = { "OfflineRewards1" },
				buttonType = "Button"
			},
			OfflineRewards3 = {
				name = "Offline Earnings III",
				description = "Get 30% more offline earnings",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-4, 3),
				requires = { "OfflineRewards2" },
				buttonType = "Button"
			},
			OfflineRewards4 = {
				name = "Offline Earnings IV",
				description = "Get 40% more offline earnings",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-5, 3),
				requires = { "OfflineRewards3" },
				buttonType = "Button"
			},
			OfflineRewards5 = {
				name = "Offline Earnings V",
				description = "Get 50% more offline earnings",
				icon = "rbxassetid://17009565402",
				cost = 1000,
				position = Vector2.new(-5, 2),
				requires = { "OfflineRewards4" },
				buttonType = "Button"
			}
		}
	},
	SKILL_TREE_COLOURS = v
}