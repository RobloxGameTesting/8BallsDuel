local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local ToolAssets = ReplicatedStorage.Assets.ToolAssets
local DualUzis = {}
DualUzis.id = script.Name
DualUzis.description = "One of the fastest firerate weapons releasing hundreds of bullets in the blind of an eye"
DualUzis.instance = ToolAssets.Tools["Dual Uzis"].Weapon
DualUzis.viewModel = ToolAssets.Tools["Dual Uzis"].Viewmodel
DualUzis.toolType = "Secondary"
DualUzis.masteryType = "Light"

function DualUzis.labelTop(): string
	return "Dual"
end

function DualUzis.labelBottom(): string
	return "Uzis"
end

function DualUzis.image(): string
	return "rbxassetid://76044720385776"
end

function DualUzis.rarity(): string
	return "Golden"
end

DualUzis.display = { "Damage", "Firerate", "Accuracy", "Knockback" }
DualUzis.cost = 440
DualUzis.moneyCost = 3300
DualUzis.spread = 0
DualUzis.ammo = 45
DualUzis.totalAmmo = 900
DualUzis.headshotMultiplier = 1.25
DualUzis.reloadTime = 2
DualUzis.spray = {
	{
		viewmodelAnimationSequence = {
			{ animation = "shoot", priority = Enum.AnimationPriority.Action }
		},
		animationSequence = {
			{ animation = "shoot", priority = Enum.AnimationPriority.Action }
		},
		extraData = { arm = "Left" },
		origin = { "LeftOrigin" },
		viewmodelOrigin = { "LeftOrigin" },
		cooldown = 0.1,
		pattern = {
			{ attackType = "Bullet", attackId = "WeakBullet", angle = 0, flat = false }
		},
		spread = { min = -3, max = 3 },
		spreadY = { min = 0, max = 0 }
	},
	{
		extraData = { arm = "Right" },
		origin = { "RightOrigin" },
		viewmodelOrigin = { "RightOrigin" },
		cooldown = 0.1,
		pattern = {
			{ attackType = "Bullet", attackId = "WeakBullet", angle = 0, flat = false }
		},
		spread = { min = -4, max = 4 },
		spreadY = { min = 0, max = 1 }
	}
}

DualUzis.visuals = {
	shootRight = {
		id = { "Weapons", "MuzzleFlash" },
		parent = { "RightMuzzle" },
		viewmodelParent = { "RightMuzzle" }
	},
	shootLeft = {
		id = { "Weapons", "MuzzleFlash" },
		parent = { "LeftMuzzle" },
		viewmodelParent = { "LeftMuzzle" }
	}
}

DualUzis.sounds = {
	shooting = {
		id = { "Dual Uzis", "Shooting" },
		parent = { "RightMuzzle" },
		viewmodelParent = { "RightMuzzle" }
	},
	stop = {
		id = { "Dual Uzis", "Stop" },
		parent = { "RightMuzzle" },
		viewmodelParent = { "LeftMuzzle" }
	}
}

DualUzis.animations = {
	idle = 15991010459,
	press = 15991013991,
	pressIdle = 16032026667,
	shoot = 16032139554,
	reload = 136631577781479
}

DualUzis.viewModelAnimations = {
	equip = 128878348976808,
	idle = 97067986252213,
	shoot = 138257980132173,
	reload = 121603010361834
}

DualUzis.grip = {
	{
		C0 = CFrame.new(
			-0.024000000208616257,
			-1.1109999418258667,
			-0.16599999368190765,
			1,
			-0,
			0,
			0,
			-4.371138828673793e-8,
			1,
			0,
			-1,
			-4.371138828673793e-8
		),
		C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		Part0 = "Right Arm",
		Part1 = "Handle"
	},
	{
		C0 = CFrame.new(
			-0.017000000923871994,
			-1.0709999799728394,
			-0.16599999368190765,
			1,
			-0,
			0,
			0,
			-4.371138828673793e-8,
			1,
			0,
			-1,
			-4.371138828673793e-8
		),
		C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		Part0 = "Left Arm",
		Part1 = "Handle 2"
	}
}
return DualUzis