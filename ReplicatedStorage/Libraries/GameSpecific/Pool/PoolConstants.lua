local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local PoolConstants = {}
PoolConstants.PlayWidth = 88
PoolConstants.PlayHeight = 44
PoolConstants.FrameWidth = 103
PoolConstants.FrameHeight = 59
PoolConstants.RailDepth = 7.5
PoolConstants.BezelDepth = 2
PoolConstants.CushionDepth = 2
PoolConstants.BallDiameter = 2.25
PoolConstants.BallRadius = 1.125
PoolConstants.CueBallNumber = 0
PoolConstants.EightBallNumber = 8
PoolConstants.Solids = { 1, 2, 3, 4, 5, 6, 7 }
PoolConstants.Stripes = { 9, 10, 11, 12, 13, 14, 15 }
PoolConstants.RackJitter = 0.1
PoolConstants.CornerPocketMouth = 4.5
PoolConstants.SidePocketMouth = 5
PoolConstants.CornerFacingFlare = 0
PoolConstants.SideFacingFlare = -14
PoolConstants.CornerBowlOffsetScale = 1.4
PoolConstants.SideBowlOffsetScale = 0.8
PoolConstants.BowlDiameterScale = 1
PoolConstants.CornerMouthDepth = 2.6
PoolConstants.SideMouthDepth = 0.3
PoolConstants.SinkSpeed = 45
PoolConstants.MaxSinkSpeed = 110
PoolConstants.Physics = {
	RollingDeceleration = 10,
	SlidingDeceleration = 0,
	SpinDecay = 1.2,
	CushionRestitution = 0.72,
	CushionFriction = 0.2,
	BallRestitution = 0.94,
	StopSpeed = 0.5,
	MaxShotSpeed = 138,
	MinShotSpeed = 30,
	MaxSubSteps = 128,
	TeeterSeconds = 4,
	TeeterRadius = 4.5,
	BreakSpeedMultiplier = 2.5,
	PowerCurve = 2,
	SpinTransferFraction = 0.35,
	CushionSpinTransfer = 22,
	JawCaptureDot = 0.55,
	JawZoneRadius = 2.5,
	JawZoneCaptureDot = 0.94
}

PoolConstants.Feel = {
	BallHitSound = { "Pool", "Ball Hitv1" },
	BallHitMinSpeed = 2,
	BallHitLoudSpeed = 120,
	BallHitMinVolume = 0.18,
	BallHitMaxVolume = 1,
	BallHitMinPlaybackSpeed = 0.92,
	BallHitMaxPlaybackSpeed = 1.1,
	BallHitPlaybackJitter = 0.04,
	BallHitMaxVoices = 6,
	BallHitBurstWindow = 0.015
}

PoolConstants.SoundCues = {
	MenuOpen = {
		Path = { "UserInterface", "MenuOpen" },
		Volume = 0.35,
		Speed = 1.15
	},
	Pocket = {
		Path = { "Pool", "Ball Pocket" },
		Volume = 0.85,
		Speed = 0.9
	},
	CueSoft = {
		Path = { "Pool", "Cue Hit" },
		Volume = 0.5,
		Speed = 0.85
	},
	CueHard = {
		Path = { "Pool", "Ball Hit Heavy v2" },
		Volume = 0.9,
		Speed = 1.2
	},
	CueHardThreshold = 0.5,
	TurnStart = {
		Path = { "Pool", "Menu Pop Up" },
		Volume = 0.45,
		Speed = 1
	},
	TurnStartBallInHand = {
		Path = { "NicoMine", "Item3" },
		Volume = 0.6,
		Speed = 1.3
	},
	MatchFound = {
		Path = { "NicoMine", "Player Gadget - Brawl Stars SFX" },
		Volume = 0.9,
		Speed = 1.1
	},
	MatchStart = {
		Path = { "NicoMine", "Mario Kart 8 - Item Decide" },
		Volume = 0.9,
		Speed = 0.95
	},
	TurnClock = {
		Path = { "UserInterface", "Tick" },
		Volume = 0.45,
		Speed = 1
	},
	TurnClockTickFrom = 5,
	RackRoll = {
		Path = { "Pool", "BallRoll" },
		Volume = 0.3,
		Speed = 0.75
	},
	MatchOver = {
		Path = { "PackOpening", "Timeskip (old)" },
		Volume = 0.5,
		Speed = 1
	},
	MatchWin = {
		Path = { "Medium" },
		Volume = 1.6,
		Speed = 1
	},
	MatchLoss = {
		Path = { "AdminAbuseSounds", "Windows Error" },
		Volume = 0.5,
		Speed = 1
	},
	MatchVerdictDelay = 1.5,
	PayoutCoin1 = {
		Path = { "Money", "Coin Throws 1 (SFX)" },
		Volume = 0.5,
		Speed = 1
	},
	PayoutCoin2 = {
		Path = { "Money", "Coin Throws 2 (SFX)" },
		Volume = 0.5,
		Speed = 1
	},
	PayoutCoin3 = {
		Path = { "Money", "Coin Throws 3 (SFX)" },
		Volume = 0.5,
		Speed = 1
	}
}

PoolConstants.DragAimGain = { 0.3, 0.45, 0.6, 0.8, 1 }
PoolConstants.DefaultDragAimLevel = 5
PoolConstants.AimArt = {
	AimLine = {
		Image = "rbxassetid://72109058483579",
		Transparency = 0,
		ScaleType = "Slice",
		SliceCenter = Rect.new(74, 12, 74, 12),
		SliceSourceHeight = 8,
		TileSize = nil
	},
	ObjectLine = {
		Image = "rbxassetid://72109058483579",
		Transparency = 0,
		ScaleType = "Slice",
		SliceCenter = Rect.new(74, 12, 74, 12),
		SliceSourceHeight = 9,
		TileSize = nil
	},
	CueLine = {
		Image = "rbxassetid://72109058483579",
		Transparency = 0,
		ScaleType = "Slice",
		SliceCenter = Rect.new(74, 12, 74, 12),
		SliceSourceHeight = 9,
		TileSize = nil
	},
	Ghost = {
		Image = "rbxassetid://112655515082437",
		Transparency = 0,
		ScaleType = "Fit",
		SliceCenter = nil,
		TileSize = nil
	},
	CueStick = {
		Image = "",
		Transparency = 0,
		ScaleType = "Slice",
		SliceCenter = nil,
		TileSize = nil
	}
}

PoolConstants.HeldBallHalo = {
	Scale = 5,
	Transparency = 0.5,
	Colour = Color3.fromRGB(255, 255, 255)
}

PoolConstants.VisualCues = {
	ReferenceBallDiameter = 6.15,
	BallInHand = {
		Path = { "InHand" },
		Timer = "Manual",
		Colour = Color3.fromRGB(255, 255, 255)
	},
	YourBalls = {
		Path = { "PoolHighlight" },
		Timer = nil,
		Colour = Color3.fromRGB(120, 220, 255)
	},
	YourBallsDark = {
		Path = { "PoolHighlight" },
		Timer = nil,
		Colour = Color3.fromRGB(0, 0, 0),
		LightEmission = 0
	},
	Potted = {
		Path = { "BombExplosion" },
		Timer = nil,
		Colour = Color3.fromRGB(255, 214, 120)
	},
	PottedHeight = 1.5
}

PoolConstants.Identities = {
	BotIcon = "rbxassetid://125421487089411",
	Offline = {
		{ Name = "Blue", Icon = "rbxassetid://527252426" },
		{ Name = "Red", Icon = "rbxassetid://171886351" }
	}
}

PoolConstants.Bots = {
	Levels = {
		{
			Id = "Beginner",
			Name = "Beginner",
			Blurb = "Still finding the cue ball",
			Rating = 600,
			AimError = 0.76,
			MissAimChance = 45,
			MissBadly = 0.7,
			FinalBallSuccessChance = 2,
			PowerError = 0.3,
			FullPower = true,
			Candidates = 1,
			PositionWeight = 0,
			ThinkTime = 0.5
		},
		{
			Id = "Rookie",
			Name = "Rookie",
			Blurb = "Just learning the table",
			Rating = 800,
			AimError = 0.62,
			MissAimChance = 30,
			MissBadly = 0.55,
			FinalBallSuccessChance = 5,
			PowerError = 0.22,
			FullPower = true,
			Candidates = 2,
			PositionWeight = 0,
			ThinkTime = 0.5
		},
		{
			Id = "Amateur",
			Name = "Amateur",
			Blurb = "Knows the angles, not the follow-up",
			Rating = 1050,
			AimError = 0.35,
			MissAimChance = 20,
			MissBadly = 0.4,
			FinalBallSuccessChance = 9,
			PowerError = 0.15,
			Candidates = 3,
			PositionWeight = 0.15,
			ThinkTime = 0.6
		},
		{
			Id = "Regular",
			Name = "Regular",
			Blurb = "Punishes a loose table",
			Rating = 1300,
			AimError = 0.14,
			MissAimChance = 10,
			MissBadly = 0.25,
			FinalBallSuccessChance = 14,
			PowerError = 0.1,
			Candidates = 4,
			PositionWeight = 0.35,
			ThinkTime = 0.7,
			BreakStrategic = true,
			BreakScratchChance = 0.75
		},
		{
			Id = "Shark",
			Name = "Shark",
			Blurb = "Plays the ball after this one",
			Rating = 1550,
			AimError = 0.05,
			MissAimChance = 0,
			MissBadly = 0.1,
			PowerError = 0.045,
			FinalBallSuccessChance = 20,
			SoftPowers = { 0.25, 0.35 },
			Candidates = 5,
			PositionWeight = 0.55,
			ThinkTime = 0.8,
			BreakStrategic = true,
			BreakScratchChance = 0.75
		},
		{
			Id = "Legend",
			Name = "Legend",
			Blurb = "Runs the table if you let it",
			Rating = 1850,
			AimError = 0.02,
			MissAimChance = 0,
			MissBadly = 0,
			PowerError = 0.015,
			SoftPowers = { 0.25, 0.35 },
			Candidates = 6,
			PositionWeight = 0.7,
			ThinkTime = 0.9,
			BreakStrategic = true,
			BreakScratchChance = 0.75
		}
	},
	MaxContactOffset = 0.92,
	ContactRetries = 6,
	ContactBackoff = 0.55,
	MissAimStart = 0.25,
	MissAimGrowth = 1.5,
	MissAimTries = 3,
	NearMiss = {
		KeepBeyond = 0.25,
		Min = 0.05,
		MaxSteady = 0.45,
		MaxSevere = 4,
		SeverityWidths = 4,
		DeliberateBias = 1.6,
		BelievableAngle = 25,
		DefaultMissBadly = 0.3,
		Jitter = 0.15,
		Floor = -0.1,
		Step = 0.35,
		StepGrowth = 1.5,
		Tries = 4,
		TrafficStep = 0.25,
		MaxTrafficSteps = 12,
		MaxAngle = 50
	},
	BankErrorScale = 2.5,
	SoftPotMargin = 0.08,
	SoftPotLines = 3,
	SoftPotMaxDistance = 50,
	Carry = {
		BaseSeconds = 0.6,
		SecondsPerStud = 0.012,
		Seconds = { Min = 0.75, Max = 1.6 },
		Jitter = 0.15,
		PrimaryShare = { Min = 0.66, Max = 0.8 },
		PeakAt = { Min = 0.28, Max = 0.45 },
		Bend = { Min = 0.04, Max = 0.12 },
		Wobble = { Min = 0.008, Max = 0.025 },
		WobbleParts = 2,
		WobbleFrequency = { Min = 0.7, Max = 2.6 },
		MaxWobble = 1,
		Undershoot = { Min = 0.03, Max = 0.09 },
		OvershootChance = 0.35,
		Overshoot = { Min = 0.02, Max = 0.05 },
		LandingSideError = 0.035,
		MaxLandingError = 2.5,
		CorrectionPause = { Min = 0.015, Max = 0.05 },
		SecondCorrectionChance = 0.3,
		Tremor = { Min = 0.02, Max = 0.06 },
		TremorFrequency = { Min = 7, Max = 12 },
		PaceWobble = { Min = 0, Max = 0.035 },
		PaceFrequency = { Min = 1, Max = 2.2 }
	},
	CatchUp = {
		Deficit = 3,
		Pots = { Min = 1, Max = 2 },
		SearchLines = 6,
		Powers = { 0.55, 0.8, 1 }
	},
	DynamicMiss = {
		Enabled = true,
		Leads = { -3, -2, -1, 0, 1, 2, 3 },
		Chances = {
			Beginner = { 22, 29, 32, 50, 85, 90, 95 },
			Rookie = { 20, 26, 30, 50, 75, 80, 85 },
			Amateur = { 18, 25, 30, 50, 55, 60, 65 },
			Regular = { 15, 20, 29, 40, 45, 50, 55 },
			Shark = { 10, 13, 27, 33, 36, 39, 42 },
			Legend = { 1, 2, 3, 15, 20, 23, 26 }
		},
		WinningShot = {
			Beginner = 96,
			Rookie = 92,
			Amateur = 85,
			Regular = 75,
			Shark = 65,
			Legend = 25
		},
		ShotDifficultyWeight = 0.25,
		MaxChance = 98,
		PrintInStudio = true
	},
	JudgementQualityWeight = 120,
	JudgementDistanceWeight = 42,
	Theatre = {
		MinBalls = 1,
		MaxBalls = 3,
		BallCountWeights = { 2, 3, 1 },
		MaxSpotsPerBall = 2,
		MaxLooks = 6,
		TurnSeconds = { Min = 3, Max = 8 },
		SettleSeconds = { Min = 2, Max = 3.5 },
		MinSettleSeconds = 0.9,
		ChargeFillSeconds = 0.12,
		ChargeHoldSeconds = { Min = 0.5, Max = 0.65 },
		MinBrowseSeconds = 0.6,
		MinLookSeconds = 0.35,
		OnBallFraction = { Min = 0.5, Max = 1 },
		OffBallDegrees = { Min = 12, Max = 55 },
		OverAimChance = { Min = 0, Max = 0.5 },
		OverAimDegrees = { Min = 2.5, Max = 7 },
		DragSegments = { Min = 1, Max = 3 },
		DragPauseSeconds = { Min = 0.04, Max = 0.2 },
		DragWanderDegrees = 7,
		PlaceHoldSeconds = { Min = 1.6, Max = 2.4 },
		ReconsiderChance = 0.2,
		ReconsiderHoldSeconds = { Min = 0.5, Max = 0.9 },
		SweepSlow = 0.45,
		SweepFast = 0.15,
		RestSlow = 0.5,
		RestFast = 0.16,
		Jitter = 0.35,
		LongShot = 140,
		MinAdjustments = 2,
		MaxAdjustments = 5,
		AdjustDegrees = 0.9,
		MissApproachDegrees = { Min = 0.6, Max = 1.8 },
		MissSideDegrees = 0.12,
		AdjustSweep = 0.13,
		AdjustRest = 0.55,
		CommitSweep = 0.18,
		MaxAimDegreesPerSecond = 90
	},
	MinimumTurn = 1,
	PlaceSeconds = 0.65,
	MatchRatingOffset = -40,
	MaxBankProposals = 4,
	LevelTraits = {
		Beginner = {
			TurnSeconds = { Min = 2.5, Max = 9 },
			SpinUse = 0,
			PositionDepth = false,
			PlaysSafeties = false,
			PressureError = 1.3
		},
		Rookie = {
			TurnSeconds = { Min = 3, Max = 8.5 },
			SpinUse = 0,
			PositionDepth = false,
			PlaysSafeties = false,
			PressureError = 1.3
		},
		Amateur = {
			TurnSeconds = { Min = 3, Max = 8 },
			SpinUse = 0,
			PositionDepth = false,
			PlaysSafeties = false,
			PressureError = 1.25
		},
		Regular = {
			TurnSeconds = { Min = 3, Max = 7.5 },
			SpinUse = 1,
			PositionDepth = true,
			PlaysSafeties = false,
			PressureError = 1.2
		},
		Shark = {
			TurnSeconds = { Min = 3.5, Max = 7.5 },
			SpinUse = 2,
			PositionDepth = true,
			PlaysSafeties = false,
			PressureError = 1.15
		},
		Legend = {
			TurnSeconds = { Min = 3, Max = 7 },
			SpinUse = 2,
			PositionDepth = true,
			PlaysSafeties = true,
			PressureError = 1.1
		}
	},
	Styles = {
		{
			Id = "Steady",
			Weight = 3,
			Tempo = 1,
			PowerBias = 0,
			Risk = 1,
			BankLove = 0,
			Fidget = 1,
			Nerves = 1,
			PullSeconds = { Min = 0.5, Max = 0.7 },
			BreakWeights = { HeadOn = 3, SecondBall = 2, Control = 5 }
		},
		{
			Id = "Grinder",
			Weight = 2,
			Tempo = 1.3,
			PowerBias = -0.12,
			Risk = 0.7,
			BankLove = 0,
			Fidget = 1.3,
			Nerves = 0.8,
			PullSeconds = { Min = 0.8, Max = 1.1 },
			BreakWeights = { HeadOn = 2, SecondBall = 2, Control = 6 }
		},
		{
			Id = "Slugger",
			Weight = 2,
			Tempo = 0.75,
			PowerBias = 0.15,
			Risk = 1.25,
			BankLove = 0.1,
			Fidget = 0.7,
			Nerves = 1,
			PullSeconds = { Min = 0.22, Max = 0.35 },
			BreakWeights = { HeadOn = 7, SecondBall = 2, Control = 1 }
		},
		{
			Id = "Showboat",
			Weight = 1.5,
			Tempo = 0.9,
			PowerBias = 0.05,
			Risk = 1.4,
			BankLove = 1,
			Fidget = 0.9,
			Nerves = 0.9,
			PullSeconds = { Min = 0.35, Max = 0.5 },
			BreakWeights = { HeadOn = 3, SecondBall = 6, Control = 1 }
		},
		{
			Id = "Nervous",
			Weight = 1.5,
			Tempo = 1.15,
			PowerBias = -0.05,
			Risk = 0.85,
			BankLove = 0,
			Fidget = 1.5,
			Nerves = 1.6,
			PullSeconds = { Min = 0.7, Max = 1 },
			BreakWeights = { HeadOn = 5, SecondBall = 2, Control = 3 }
		}
	},
	Human = {
		DistanceBase = 0.7,
		DistanceScale = 0.6,
		CutBase = 0.8,
		CutScale = 0.5,
		FormSpread = 0.15,
		StreakBonus = 0.06,
		StreakCap = 3,
		TiltPenalty = 0.08,
		TiltCap = 2,
		SpinBasic = { Vector2.new(0, 0.55), Vector2.new(0, -0.65) },
		SpinSide = { Vector2.new(0.5, 0), Vector2.new(-0.5, 0) },
		SpinTopCandidates = 2,
		SpinError = 0.12,
		SafetyTargets = 4,
		SafetyContacts = { 0, 0.4, -0.4 },
		SafetyPowers = { 0.3, 0.5 },
		SafetyMaxOpponentChance = 0.45,
		HardShotTimeScale = 0.35,
		PlacementFussChance = 0.35,
		PlacementFussNudges = { Min = 1, Max = 2 },
		PlacementFussDistance = { Min = 0.25, Max = 0.6 },
		PlacementFussSeconds = { Min = 0.22, Max = 0.38 },
		PlacementFussHoldSeconds = { Min = 0.12, Max = 0.3 }
	},
	Break = {
		Power = 1,
		HeadOnOffCentre = { Min = 1.5, Max = 4.5 },
		SecondBallRailGap = { Min = 3, Max = 4 },
		SecondBallMargin = 0.06,
		ControlSpin = Vector2.new(0, -0.3),
		GuardTries = 6,
		LooseHits = {
			{ Offset = 0.5, Spin = Vector2.new(0, 0.6) },
			{ Offset = -0.5, Spin = Vector2.new(0, 0.6) },
			{ Offset = 0.15, Spin = Vector2.new(0, 0.6) },
			{ Offset = -0.15, Spin = Vector2.new(0, 0.6) },
			{ Offset = 0.3, Spin = Vector2.new(0, 0.6) },
			{ Offset = -0.3, Spin = Vector2.new(0, 0.6) },
			{ Offset = 0.65, Spin = Vector2.new(0, 0.9) },
			{ Offset = -0.65, Spin = Vector2.new(0, 0.9) },
			{ Offset = 0.4, Spin = Vector2.new(0, 0.9) },
			{ Offset = -0.4, Spin = Vector2.new(0, 0.9) },
			{ Offset = 0.8, Spin = Vector2.new(0, 0.6) },
			{ Offset = -0.8, Spin = Vector2.new(0, 0.6) }
		},
		SimFrameBudget = 0.004,
		DefaultWeights = { HeadOn = 4, SecondBall = 2, Control = 3 }
	},
	Mimic = {
		MinTurns = 50,
		MinBallInHandTurns = 5,
		MinBreaks = 3,
		MaxTurnSeconds = 15,
		Window = 200,
		ReferencePower = 0.6,
		ReferenceReach = 38,
		ReferenceReversals = 3,
		SpinThreshold = 0.15,
		KickToBankLove = 5
	}
}

PoolConstants.Rules = {
	DefaultTurnTime = 40,
	BreakMinimumRailContacts = 4,
	BreakScratchGivesBallInHand = true,
	EightOnBreakRespots = true,
	TableOpenAfterBreak = true
}
PoolConstants.BasePredictionLength = 7.2
PoolConstants.MaxPredictionBounces = 1
PoolConstants.Input = { MaxPullDistance = 26, MinimumPower = 0.03, PowerMeterTouchPadding = 26 }
PoolConstants.CueStatMax = 10
PoolConstants.CueStatOrder = { "Time", "Spin", "Aim", "Force" }

PoolConstants.CueStatScale = {
	Time = { Zero = 0, Ten = 8 },
	Spin = { Zero = 1, Ten = 1.6 },
	Aim = { Zero = 1, Ten = 2.6 },
	Force = { Zero = 1, Ten = 1.5 }
}

PoolConstants.CueStatInfo = {
	Time = {
		Label = "TIME",
		Colour = Color3.fromRGB(88, 174, 252),
		Blurb = "Time affects how fast the timer runs down. If you're playing on a fast turns table, or like to slow down for perfect shots, consider using Cues with lots of Time!"
	},
	Spin = {
		Label = "SPIN",
		Colour = Color3.fromRGB(168, 118, 246),
		Blurb = "Spin affects how you control hits on the Cue Ball. If you're a trickshots pro, or need more control over every shot, be sure to choose a Cue stacked with extra Spin!"
	},
	Aim = {
		Label = "AIM",
		Colour = Color3.fromRGB(114, 220, 120),
		Blurb = "Aim affects the length of your guideline. If you're shooting far across the table, or want to pocket a particularly tricky ball, some extra Aim on your Cue will make all the difference!"
	},
	Force = {
		Label = "FORCE",
		Colour = Color3.fromRGB(242, 96, 78),
		Blurb = "Force affects the power of your shot. If you want to send the Cue Ball bouncing around the table, or need to break through obstructions, choose a Cue fortified with plenty of Force!"
	}
}

PoolConstants.Cues = {
	Starter = {
		DisplayName = "Starter Cue",
		Time = 1,
		Spin = 1,
		Aim = 1,
		Force = 1
	},
	Briar = {
		DisplayName = "Briarwood",
		Time = 2,
		Spin = 1,
		Aim = 1,
		Force = 2
	},
	Ivory = {
		DisplayName = "Blue Laminate",
		Time = 2,
		Spin = 1,
		Aim = 2,
		Force = 2
	},
	Summer = {
		DisplayName = "Summer",
		Time = 2,
		Spin = 2,
		Aim = 2,
		Force = 2
	},
	Archer = {
		DisplayName = "Archer's Rest",
		Time = 2,
		Spin = 2,
		Aim = 2,
		Force = 2
	},
	Gilded = {
		DisplayName = "Gilded Archer",
		Time = 2,
		Spin = 2,
		Aim = 2,
		Force = 3
	},
	Shaded = {
		DisplayName = "Green Charm",
		Time = 2,
		Spin = 2,
		Aim = 3,
		Force = 2
	},
	Obsidian = {
		DisplayName = "Obsidian",
		Time = 2,
		Spin = 2,
		Aim = 3,
		Force = 3
	},
	Arctic_Flow_Tier_2 = {
		DisplayName = "Arctic Breath",
		Time = 1,
		Spin = 2,
		Aim = 2,
		Force = 2
	},
	Crimson_Dragon_Tier_2 = {
		DisplayName = "Crimson Dragon",
		Time = 2,
		Spin = 2,
		Aim = 1,
		Force = 2
	},
	Prism_Alloy_Tier_2 = {
		DisplayName = "Rainbow Prism",
		Time = 2,
		Spin = 1,
		Aim = 2,
		Force = 2
	},
	Galaxy_Cue_Tier_1 = {
		DisplayName = "Galaxy Cue T1",
		Time = 2,
		Spin = 1,
		Aim = 2,
		Force = 2
	},
	Galaxy_Cue_Tier_2 = {
		DisplayName = "Galaxy Cue T2",
		Time = 2,
		Spin = 3,
		Aim = 3,
		Force = 3
	},
	Galaxy_Cue_Tier_3 = {
		DisplayName = "Galaxy Cue T3",
		Time = 4,
		Spin = 3,
		Aim = 4,
		Force = 5
	},
	Galaxy_Cue_Tier_4 = {
		DisplayName = "Galaxy Cue T4",
		Time = 5,
		Spin = 5,
		Aim = 6,
		Force = 8
	},
	Galaxy_Cue_Tier_5 = {
		DisplayName = "Galaxy Cue T5",
		Time = 5,
		Spin = 6,
		Aim = 7,
		Force = 8
	},
	Astra_Cue_Tier_2 = {
		DisplayName = "Astra Cue T2",
		Time = 2,
		Spin = 4,
		Aim = 2,
		Force = 4
	},
	Astra_Cue_Tier_3 = {
		DisplayName = "Astra Cue T3",
		Time = 6,
		Spin = 2,
		Aim = 3,
		Force = 5
	},
	Astra_Cue_Tier_4 = {
		DisplayName = "Astra Cue T4",
		Time = 6,
		Spin = 5,
		Aim = 5,
		Force = 8
	},
	Astra_Cue_Tier_5 = {
		DisplayName = "Astra Cue T5",
		Time = 5,
		Spin = 7,
		Aim = 6,
		Force = 9
	},
	Gold_Sapphire_Tier_4 = {
		DisplayName = "Royal Sapphire",
		Time = 3,
		Spin = 2,
		Aim = 3,
		Force = 3
	},
	Ion_Rift_Tier_3 = {
		DisplayName = "Sci-Fi",
		Time = 2,
		Spin = 3,
		Aim = 3,
		Force = 3
	},
	Skyfeather_Cue_Tier_3 = {
		DisplayName = "Skyfeather",
		Time = 2,
		Spin = 3,
		Aim = 2,
		Force = 3
	},
	Atlantis_Tier_3 = {
		DisplayName = "Trident",
		Time = 3,
		Spin = 2,
		Aim = 2,
		Force = 2
	},
	Emerald_Fracture_Tier_2 = {
		DisplayName = "Emerald Fracture",
		Time = 2,
		Spin = 3,
		Aim = 2,
		Force = 4
	},
	Spider_Cue_Tier_1 = {
		DisplayName = "Spider Cue",
		Time = 3,
		Spin = 3,
		Aim = 3,
		Force = 3
	},
	Moonblossom_Cue_Tier_2 = {
		DisplayName = "Moonblossom Cue",
		Time = 4,
		Spin = 5,
		Aim = 2,
		Force = 3
	},
	Longblade_Tier_2 = {
		DisplayName = "Longblade",
		Time = 4,
		Spin = 3,
		Aim = 4,
		Force = 4
	},
	Flaming_Tier_2 = {
		DisplayName = "Flaming",
		Time = 2,
		Spin = 3,
		Aim = 3,
		Force = 5
	},
	Gamer_Tier_1 = {
		DisplayName = "Neon",
		Time = 1,
		Spin = 2,
		Aim = 2,
		Force = 2
	},
	Lava_Core_Tier_4 = {
		DisplayName = "Lava Core",
		Time = 4,
		Spin = 4,
		Aim = 4,
		Force = 6
	},
	Jungle_Tier_2 = {
		DisplayName = "Jungle",
		Time = 2,
		Spin = 1,
		Aim = 2,
		Force = 2
	},
	Emerald_Tier_2 = {
		DisplayName = "Emerald",
		Time = 2,
		Spin = 2,
		Aim = 3,
		Force = 3
	},
	Starry_Eyes_Tier_2 = {
		DisplayName = "Starry",
		Time = 2,
		Spin = 2,
		Aim = 3,
		Force = 4
	},
	VIP_Cue = {
		DisplayName = "VIP Cue",
		Time = 3,
		Spin = 4,
		Aim = 3,
		Force = 4
	},
	Daily_Cue = {
		DisplayName = "Daily Cue",
		Time = 3,
		Spin = 4,
		Aim = 3,
		Force = 4
	},
	Daily_Cue_3 = {
		DisplayName = "Day 3 Cue",
		Time = 2,
		Spin = 3,
		Aim = 3,
		Force = 3
	},
	Camo_Cue_T1 = {
		DisplayName = "Camo Cue",
		Time = 2,
		Spin = 2,
		Aim = 2,
		Force = 2
	},
	Razorsteel_Cue_T2 = {
		DisplayName = "Razorsteel Cue",
		Time = 4,
		Spin = 3,
		Aim = 3,
		Force = 4
	},
	Alchemy_Cue_T3 = {
		DisplayName = "Alchemy Cue",
		Time = 7,
		Spin = 4,
		Aim = 3,
		Force = 3
	},
	Golden_Core_Cue_T3 = {
		DisplayName = "Golden Core Cue",
		Time = 3,
		Spin = 5,
		Aim = 5,
		Force = 5
	},
	Ironclad_Cue_T4 = {
		DisplayName = "Ironclad Cue",
		Time = 5,
		Spin = 6,
		Aim = 5,
		Force = 9
	},
	Dragon_Summoner_Cue_T4 = {
		DisplayName = "Dragon Summoner Cue",
		Time = 5,
		Spin = 6,
		Aim = 6,
		Force = 7
	},
	Spooky_Tier_1_Cue = {
		DisplayName = "Spooky Cue T1",
		Time = 2,
		Spin = 2,
		Aim = 2,
		Force = 2
	},
	Witch_Cauldron_Cue_T2 = {
		DisplayName = "Witch Cauldron Cue",
		Time = 3,
		Spin = 3,
		Aim = 2,
		Force = 5
	},
	Silver_Web_Cue_T2 = {
		DisplayName = "Silver Web Cue",
		Time = 3,
		Spin = 3,
		Aim = 2,
		Force = 5
	},
	Amberfall_Autumn_T2 = {
		DisplayName = "Amberfall Autumn",
		Time = 5,
		Spin = 3,
		Aim = 3,
		Force = 3
	},
	Bloomcrown_Spring_T2 = {
		DisplayName = "Bloomcrown Spring",
		Time = 4,
		Spin = 4,
		Aim = 2,
		Force = 4
	},
	Frost_Crown_Winter_T3 = {
		DisplayName = "Frost Crown Winter",
		Time = 5,
		Spin = 4,
		Aim = 2,
		Force = 6
	},
	Solstice_Summer_T3 = {
		DisplayName = "Solstice Summer",
		Time = 5,
		Spin = 4,
		Aim = 4,
		Force = 5
	},
	Requiem_Skull_Cue_T3 = {
		DisplayName = "Requiem Skull Cue",
		Time = 6,
		Spin = 4,
		Aim = 4,
		Force = 5
	},
	Violet_Edge_Sword_Cue_T3 = {
		DisplayName = "Violet Edge Sword Cue",
		Time = 7,
		Spin = 3,
		Aim = 3,
		Force = 6
	},
	Dreadlight_Pumpkin_T4 = {
		DisplayName = "Dreadlight Pumpkin",
		Time = 6,
		Spin = 6,
		Aim = 6,
		Force = 6
	},
	Widow_Web_Cue_T4 = {
		DisplayName = "Widow Web Cue",
		Time = 6,
		Spin = 6,
		Aim = 5,
		Force = 7
	},
	Soulreaper_Scythe_T5 = {
		DisplayName = "Soulreaper Scythe",
		Time = 5,
		Spin = 7,
		Aim = 6,
		Force = 9
	},
	Dreadhorn_Halloween_Cue_T5 = {
		DisplayName = "Dreadhorn Halloween Cue",
		Time = 7,
		Spin = 7,
		Aim = 8,
		Force = 8
	},
	Spooky_Tier_2_Cue = {
		DisplayName = "Spooky Cue T2",
		Time = 4,
		Spin = 4,
		Aim = 3,
		Force = 4
	},
	Spooky_Tier_3_Cue = {
		DisplayName = "Spooky Cue T3",
		Time = 6,
		Spin = 4,
		Aim = 3,
		Force = 5
	},
	Spooky_Tier_4_Cue = {
		DisplayName = "Spooky Cue T4",
		Time = 5,
		Spin = 6,
		Aim = 6,
		Force = 8
	},
	Spooky_Tier_5_Cue = {
		DisplayName = "Spooky Cue T5",
		Time = 5,
		Spin = 7,
		Aim = 8,
		Force = 10
	}
}
PoolConstants.DefaultCue = "Starter"
PoolConstants.CueUpgradeMaxLevel = 3
PoolConstants.CueUpgradeLevelOverrides = { Starter = 1 }
PoolConstants.CueUpgradeCostPerPoint = 400
PoolConstants.CueUpgradeStep = 1

function PoolConstants.CueTotal(p: string?)
	local cue = PoolConstants.GetCue(p)
	local total = 0

	for _, v in PoolConstants.CueStatOrder do
		total += tonumber(cue[v]) or 0
	end

	return total
end

function PoolConstants.CueMaxLevel(p: string?)
	local cueUpgradeLevelOverride = PoolConstants.CueUpgradeLevelOverrides[p or PoolConstants.DefaultCue]

	if typeof(cueUpgradeLevelOverride) == "number" then
		return (math.clamp(math.floor(cueUpgradeLevelOverride), 0, PoolConstants.CueUpgradeMaxLevel))
	end

	return (math.clamp(math.floor(PoolConstants.CueTotal(p) / 10), 0, PoolConstants.CueUpgradeMaxLevel))
end

function PoolConstants.CueUpgradeCost(p: string?, p2: number)
	local v = math.floor(p2) + 1

	if PoolConstants.CueMaxLevel(p) < v then
		return nil
	end

	return PoolConstants.CueTotal(p) * PoolConstants.CueUpgradeCostPerPoint * v
end

local color = Color3.fromRGB(245, 197, 24)
local color2 = Color3.fromRGB(47, 111, 224)
local color3 = Color3.fromRGB(226, 64, 47)
local color4 = Color3.fromRGB(123, 75, 209)
local color5 = Color3.fromRGB(242, 128, 43)
local color6 = Color3.fromRGB(30, 158, 88)
local color7 = Color3.fromRGB(142, 59, 46)
local color8 = Color3.fromRGB(22, 25, 28)
local color9 = Color3.fromRGB(247, 246, 241)

PoolConstants.BallColours = {
	[0] = color9,
	[1] = color,
	[2] = color2,
	[3] = color3,
	[4] = color4,
	[5] = color5,
	[6] = color6,
	[7] = color7,
	[8] = color8,
	[9] = color,
	[10] = color2,
	[11] = color3,
	[12] = color4,
	[13] = color5,
	[14] = color6,
	[15] = color7
}

PoolConstants.Themes = {
	Default = {
		Cloth = Color3.fromRGB(44, 127, 166),
		Cushion = Color3.fromRGB(58, 147, 188),
		Rail = Color3.fromRGB(122, 43, 38),
		Frame = Color3.fromRGB(42, 49, 56),
		Pocket = Color3.fromRGB(10, 17, 22),
		PocketCasing = Color3.fromRGB(71, 83, 92),
		Diamond = Color3.fromRGB(227, 217, 198),
		Accent = Color3.fromRGB(255, 217, 0)
	}
}

PoolConstants.DefaultTheme = "Default"

function PoolConstants.DescribeFee(p: number)
	local v = math.round(p)

	if v <= 0 then
		return "Free"
	end

	return NumberHelper:Separate(v)
end

PoolConstants.VenueUnlockWins = 5

PoolConstants.LegacyVenueLadder = {
	"Brazil",
	"UnitedStates",
	"Indonesia",
	"Argentina",
	"UnitedKingdom",
	"Mexico",
	"Canada",
	"Philippines",
	"Italy",
	"Thailand",
	"Germany"
}

PoolConstants.VenueRewardWins = 10

PoolConstants.BotUnlockWins = 1

function PoolConstants.BotLevelIndex(p: string)
	for k, level in PoolConstants.Bots.Levels do
		if level.Id == p then
			return k
		end
	end

	return nil
end

function PoolConstants.PreviousBotLevel(p: string)
	local botLevelIndex = PoolConstants.BotLevelIndex(p)

	if botLevelIndex then
		return PoolConstants.Bots.Levels[botLevelIndex - 1]
	end

	return nil
end

function PoolConstants.IsBotUnlocked(p, p2: string): boolean
	local botLevelIndex = PoolConstants.BotLevelIndex(p2)

	if not botLevelIndex then
		return false
	end

	local level = PoolConstants.Bots.Levels[botLevelIndex - 1]

	if not level then
		return true
	end

	if typeof(p) ~= "table" then
		return false
	end

	if (p[level.Id] or 0) >= PoolConstants.BotUnlockWins then
		return true
	end

	for i = botLevelIndex, #PoolConstants.Bots.Levels do
		if (p[PoolConstants.Bots.Levels[i].Id] or 0) > 0 then
			return true
		end
	end

	return false
end

PoolConstants.Tutorial = {
	PocketId = "FootTop",
	ObjectBallNumber = 9,
	ObjectBackFromMouth = 0.25,
	AimToleranceDegrees = 0.9,
	AimCaptureBallFraction = 0.75,
	MinShotPower = 0.4,
	HandSweepDegrees = 10,
	HandSweepSeconds = 1.8,
	PowerHandSeconds = 1.3,
	PowerHandHoldSeconds = 0.3,
	PowerHandGap = 14,
	ChargeHandGhostGapInches = 5,
	ChargeHandFromInches = 13,
	ChargeHandToInches = -17,
	ChargeHandSeconds = 2,
	PowerMeterTweenSeconds = 0.45,
	CompletionReward = 1000,
	ConsolationReward = 1000,
	FirstMatchVenueId = "Brazil",
	FirstMatchBotLevel = "Beginner",
	FakeSearchSeconds = 2.5
}

PoolConstants.VenueCoinsOverlayImage = "rbxassetid://87250578436239"

PoolConstants.Venues = {
	{
		Id = "Brazil",
		Name = "BRAZIL",
		Image = "rbxassetid://80280284570540",
		UnlockLevel = 1,
		EntryFee = 0,
		Prize = 50,
		Colour = Color3.fromRGB(246, 206, 48),
		Shade = Color3.fromRGB(172, 142, 28)
	},
	{
		Id = "UnitedStates",
		Name = "USA",
		Image = "rbxassetid://125022563084906",
		UnlockLevel = 5,
		EntryFee = 0,
		Prize = 250,
		Colour = Color3.fromRGB(62, 96, 172),
		Shade = Color3.fromRGB(40, 64, 120)
	},
	{
		Id = "Indonesia",
		Name = "INDONESIA",
		Image = "rbxassetid://120722358714140",
		UnlockLevel = 10,
		EntryFee = 0,
		Prize = 1000,
		Colour = Color3.fromRGB(212, 66, 66),
		Shade = Color3.fromRGB(146, 42, 42)
	},
	{
		Id = "Argentina",
		Name = "ARGENTINA",
		Image = "rbxassetid://136040808743383",
		CallPocket = "Eight",
		MatchType = "Call your pocket for the 8 ball",
		UnlockLevel = 15,
		EntryFee = 0,
		Prize = 2500,
		Colour = Color3.fromRGB(108, 174, 228),
		Shade = Color3.fromRGB(64, 118, 170)
	},
	{
		Id = "UnitedKingdom",
		Name = "UNITED KINGDOM",
		Image = "rbxassetid://101153577515355",
		UnlockLevel = 20,
		EntryFee = 0,
		Prize = 5000,
		Colour = Color3.fromRGB(46, 78, 158),
		Shade = Color3.fromRGB(28, 50, 108)
	},
	{
		Id = "Mexico",
		Name = "MEXICO",
		Image = "rbxassetid://97755277056875",
		UnlockLevel = 25,
		EntryFee = 0,
		Prize = 10000,
		Colour = Color3.fromRGB(28, 146, 94),
		Shade = Color3.fromRGB(18, 100, 64)
	},
	{
		Id = "Canada",
		Name = "CANADA",
		Image = "rbxassetid://96956094277490",
		UnlockLevel = 40,
		EntryFee = 0,
		Prize = 20000,
		Colour = Color3.fromRGB(216, 64, 58),
		Shade = Color3.fromRGB(152, 40, 36)
	},
	{
		Id = "Philippines",
		Name = "PHILIPPINES",
		Image = "rbxassetid://101675141509683",
		UnlockLevel = 60,
		EntryFee = 0,
		Prize = 25000,
		Colour = Color3.fromRGB(234, 178, 40),
		Shade = Color3.fromRGB(164, 120, 22)
	},
	{
		Id = "Italy",
		Name = "ITALY",
		Image = "rbxassetid://93370056009980",
		CallPocket = "Eight",
		MatchType = "Call your pocket for the 8 ball",
		UnlockLevel = 80,
		EntryFee = 0,
		Prize = 50000,
		Colour = Color3.fromRGB(38, 150, 88),
		Shade = Color3.fromRGB(24, 104, 60)
	},
	{
		Id = "Thailand",
		Name = "THAILAND",
		Image = "rbxassetid://132772885533963",
		UnlockLevel = 100,
		EntryFee = 0,
		Prize = 100000,
		Colour = Color3.fromRGB(178, 62, 96),
		Shade = Color3.fromRGB(122, 38, 64)
	},
	{
		Id = "Germany",
		Name = "GERMANY",
		Image = "rbxassetid://79269335616962",
		CoinsOverlay = true,
		UnlockLevel = 125,
		EntryFee = 0,
		Prize = 200000,
		Colour = Color3.fromRGB(212, 168, 46),
		Shade = Color3.fromRGB(146, 114, 28)
	},
	{
		Id = "Monaco",
		Name = "MONACO",
		Image = "rbxassetid://102163429313452",
		CoinsOverlay = true,
		UnlockLevel = 150,
		EntryFee = 0,
		Prize = 300000,
		Colour = Color3.fromRGB(188, 22, 52),
		Shade = Color3.fromRGB(120, 12, 32)
	},
	{
		Id = "Greece",
		Name = "GREECE",
		Image = "rbxassetid://112970356927150",
		CoinsOverlay = true,
		Matchmaking = "RealOnline",
		BotFallbackSeconds = 30,
		CallPocket = "Eight",
		MatchType = "Call your pocket for the 8 ball",
		UnlockLevel = 175,
		EntryFee = 0,
		Prize = 400000,
		Colour = Color3.fromRGB(22, 116, 218),
		Shade = Color3.fromRGB(12, 74, 148)
	},
	{
		Id = "Turkey",
		Name = "TURKEY",
		Image = "rbxassetid://71684732439240",
		CoinsOverlay = true,
		Matchmaking = "RealOnline",
		BotFallbackSeconds = 30,
		CallPocket = "Eight",
		MatchType = "Call your pocket for the 8 ball",
		UnlockLevel = 200,
		EntryFee = 0,
		Prize = 500000,
		Colour = Color3.fromRGB(32, 178, 170),
		Shade = Color3.fromRGB(18, 118, 112)
	},
	{
		Id = "Spain",
		Name = "SPAIN",
		Image = "rbxassetid://119499736214026",
		CoinsOverlay = true,
		Matchmaking = "RealOnline",
		BotFallbackSeconds = 30,
		CallPocket = "All",
		MatchType = "Call your pocket on every shot",
		UnlockLevel = 250,
		EntryFee = 0,
		Prize = 600000,
		Colour = Color3.fromRGB(238, 112, 38),
		Shade = Color3.fromRGB(166, 72, 20)
	}
}

PoolConstants.NineBallVenueId = "NineBall"

PoolConstants.NineBallVenue = {
	Id = PoolConstants.NineBallVenueId,
	Name = "9 BALL",
	Matchmaking = "Bot",
	EntryFee = 0,
	Prize = 500,
	Colour = Color3.fromRGB(38, 186, 196),
	Shade = Color3.fromRGB(22, 122, 132),
	GameType = "NineBall"
}

PoolConstants.LegacyNineBallLadder = {
	"NineBall_Mexico",
	"NineBall_Canada",
	"NineBall_Brazil",
	"NineBall_Italy",
	"NineBall_Argentina",
	"NineBall_Germany",
	"NineBall_Indonesia",
	"NineBall_UnitedKingdom",
	"NineBall_Thailand",
	"NineBall_UnitedStates",
	"NineBall_Philippines"
}

PoolConstants.NineBallMatchType = "Hit the lowest ball first, pocket the 9 to win"

PoolConstants.NineBallVenues = {}

for k, v in {
	{ "Philippines", 40, 1 },
	{ "Brazil", 200, 4 },
	{ "UnitedStates", 800, 8 },
	{ "Indonesia", 2000, 12 },
	{ "Argentina", 4000, 15 },
	{ "UnitedKingdom", 8000, 20 },
	{ "Mexico", 15000, 30 },
	{ "Canada", 20000, 50 },
	{ "Italy", 40000, 60 },
	{ "Thailand", 80000, 80 },
	{ "Germany", 140000, 100 },
	{ "Monaco", 200000, 120 },
	{ "Greece", 280000, 140 },
	{ "Turkey", 350000, 160 },
	{ "Spain", 550000, 200 }
} do
	local country = tostring(v[1])
	local prize = tonumber(v[2]) or 0
	local unlockLevel = tonumber(v[3]) or 1
	local v2 = nil

	for _, venue in PoolConstants.Venues do
		if venue.Id == country then
			v2 = venue
			break
		end
	end

	if v2 then
		local venue = PoolConstants.Venues[math.min(k, #PoolConstants.Venues)]

		local nineBallVenues = PoolConstants.NineBallVenues
		local v3 = {
			Id = "NineBall_" .. country,
			Name = v2.Name,
			Country = country,
			PlaysLike = 0,
			UnlockLevel = 0,
			Matchmaking = "Bot",
			GameType = "NineBall",
			MatchType = 0,
			EntryFee = 0,
			Prize = 0,
			Colour = 0,
			Shade = 0,
			Image = 0,
			CoinsOverlay = 0
		}
		local playsLike

		if venue then
			playsLike = venue.Id
		end

		v3.PlaysLike = playsLike
		v3.UnlockLevel = unlockLevel

		v3.MatchType = PoolConstants.NineBallMatchType

		v3.Prize = prize
		v3.Colour = v2.Colour
		v3.Shade = v2.Shade
		v3.Image = v2.Image
		v3.CoinsOverlay = v2.CoinsOverlay
		table.insert(nineBallVenues, v3)
	else
		warn(string.format("[PoolConstants] 9 ball ladder: %q is not an 8 ball country; skipped", country))
	end
end

PoolConstants.NineBall = {
	BallNumber = 9,
	Balls = {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9
	},
	HowToPlayMatches = 5,
	HighlightInterval = 1.25,
	RespotNotice = "9 ball respotted"
}

PoolConstants.FoulPopup = {
	InSeconds = 0.35,
	HoldSeconds = 2,
	OutSeconds = 0.3,
	Fouls = {
		Scratch = { Header = "SCRATCH", Body = "You pocketed the cue ball", Icon = "Scratch" },
		WrongBallFirst = {
			Header = "WRONG BALL",
			Body = "You hit the wrong ball first",
			Icon = "WrongBallFirst"
		},
		NoContact = {
			Header = "NO CONTACT",
			Body = "The cue ball didn't hit any ball",
			Icon = "NoContact"
		},
		NoRailAfterContact = {
			Header = "NO RAIL",
			Body = "A ball needs to touch the wall",
			Icon = "NoRailAfterContact"
		},
		Timeout = { Header = "TIMER", Body = "Ran out of time", Icon = "Timeout" }
	},
	NineBall = {
		WrongBallFirst = {
			Header = "WRONG BALL",
			Body = "You didn't hit the lowest ball first",
			Icon = "WrongBallFirst"
		}
	},
	Losses = {
		EightEarly = { Header = "8-BALL", Body = "Pocketed the 8 ball early", Icon = "EightEarly" },
		EightScratch = {
			Header = "8-BALL SCRATCH",
			Body = "Pocketed the cue ball and 8 ball",
			Icon = "EightScratch"
		},
		EightFoul = {
			Header = "8-BALL FOUL",
			Body = "Fouled while pocketing the 8 ball",
			Icon = "EightFoul"
		},
		EightWrongPocket = {
			Header = "WRONG POCKET",
			Body = "The 8 ball went in a pocket you didn't call",
			Icon = "EightEarly"
		}
	},
	Icons = {
		Scratch = "rbxassetid://124305022433681",
		WrongBallFirst = "rbxassetid://72322847769250",
		NoContact = "rbxassetid://97247440879607",
		NoRailAfterContact = "rbxassetid://107440561254411",
		Timeout = "rbxassetid://79556421255130",
		EightEarly = "rbxassetid://95788280989317",
		EightScratch = "rbxassetid://108123591729724",
		EightFoul = "rbxassetid://136220497630060"
	},
	IconStudioFolder = "rbxasset://textures/FoulIcons/"
}

PoolConstants.WinStreak = {
	Icon = "rbxassetid://88680743519187",
	Placeholder = "🔥",
	MinStreak = 1,
	Background = Color3.fromRGB(46, 20, 8),
	Border = Color3.fromRGB(255, 132, 30),
	Text = Color3.fromRGB(255, 255, 255),
	TextOutline = Color3.fromRGB(72, 32, 12),
	PlaceholderColour = Color3.fromRGB(255, 176, 48)
}

PoolConstants.CardArt = {
	Backs = {
		Gold = "rbxassetid://117736587237517",
		First = "rbxassetid://101226000431223",
		Silver = "rbxassetid://115752026800690",
		Wood = "rbxassetid://130167832955997"
	},
	Front = "rbxassetid://130916156461753",
	FrontCoins = "rbxassetid://86233701981523",
	StudioFolder = "rbxasset://textures/CardArt/",
	Faces = {
		Front = {
			Rarity = { 0.495, 0.125, 0.4, 0.05 },
			Picture = { 0.5, 0.478 },
			Name = { 0.5, 0.808, 0.6, 0.068 },
			NameWithKind = { 0.5, 0.796, 0.6, 0.046 },
			Kind = { 0.5, 0.83, 0.5, 0.026 },
			Tag = { 0.497, 0.913, 0.42, 0.044 }
		},
		FrontCoins = {
			Rarity = { 0.5, 0.16, 0.5, 0.07 },
			Picture = { 0.5, 0.497 },
			Name = { 0.497, 0.799, 0.56, 0.068 },
			NameWithKind = { 0.497, 0.787, 0.56, 0.046 },
			Kind = { 0.497, 0.821, 0.46, 0.026 },
			Tag = { 0.492, 0.907, 0.38, 0.044 }
		}
	}
}

function PoolConstants.GameTypeForVenue(p: string?): string
	local v

	if p then
		v = PoolConstants.GetVenue(p)
	end

	if v and v.GameType == "NineBall" then
		return "NineBall"
	end

	return "EightBall"
end

function PoolConstants.IsNineBallVenue(p: string?): boolean
	return PoolConstants.GameTypeForVenue(p) == "NineBall"
end

PoolConstants.Menu = {
	Backdrop = Color3.fromRGB(190, 78, 22),
	BurstCore = Color3.fromRGB(255, 228, 162),
	BurstMid = Color3.fromRGB(252, 150, 48),
	BurstEdge = Color3.fromRGB(178, 64, 16),
	Ray = Color3.fromRGB(255, 236, 192),
	Felt = Color3.fromRGB(46, 162, 202),
	FeltShade = Color3.fromRGB(26, 114, 154),
	Rail = Color3.fromRGB(136, 80, 44),
	RailShade = Color3.fromRGB(88, 48, 26),
	Panel = Color3.fromRGB(40, 51, 66),
	PanelShade = Color3.fromRGB(24, 31, 43),
	PlayPrimary = Color3.fromRGB(114, 220, 78),
	PlayPrimaryShade = Color3.fromRGB(58, 162, 46),
	PlayFriends = Color3.fromRGB(255, 196, 68),
	PlayFriendsShade = Color3.fromRGB(228, 140, 26),
	PlayOffline = Color3.fromRGB(158, 172, 186),
	PlayOfflineShade = Color3.fromRGB(98, 110, 124),
	Shop = Color3.fromRGB(114, 220, 78),
	FreeCoins = Color3.fromRGB(114, 220, 78),
	Competition = Color3.fromRGB(88, 174, 252),
	Gold = Color3.fromRGB(255, 216, 96),
	GoldShade = Color3.fromRGB(242, 162, 36),
	UpgradePreview = Color3.fromRGB(64, 232, 226),
	TextPrimary = Color3.fromRGB(255, 255, 255),
	TextMuted = Color3.fromRGB(218, 228, 238),
	TextOutline = Color3.fromRGB(72, 32, 12),
	CoinImage = "rbxassetid://94319039697091"
}

PoolConstants.DefaultViewMode = "3D"

PoolConstants.View3D = {
	FieldOfView = 25,
	Backdrop = {
		Inner = Color3.fromRGB(46, 68, 88),
		Outer = Color3.fromRGB(0, 27, 62),
		Rotation = 90,
		CentreStop = 0.5,
		PixelsPerStud = 8
	}
}

PoolConstants.CueStick3D = {
	UseModel = true,
	FolderPath = { "Sticks" },
	ModelName = "WornHire",
	TipGap = 1.6,
	Pullback = 9,
	Flip = false,
	Height = PoolConstants.BallDiameter
}

PoolConstants.Ball3D = {
	UseTemplate = true,
	FolderPath = { "Balls" },
	CueName = "Cue",
	GoldenName = "Golden",
	SizeMultiplier = 1,
	RollRendering = true,
	ShadowEnabled = true,
	ShadowPath = { "Assets", "BallShadow" },
	ShadowScale = 1.6,
	JumpShadowGrowth = 1.6,
	JumpShadowFade = 0.9,
	ShadowHeight = 0.02,
	DropEnabled = true,
	DropFallSeconds = 0.22,
	DropRollSeconds = 0.18,
	DropBackDepth = 2.4,
	DropHiddenDepth = 6,
	DropBackOffset = 0.55,
	DropFrontOffset = 0.55
}

PoolConstants.ShowCollisionOverlay = false

PoolConstants.Table3D = {
	UseModel = true,
	ModelFolderPath = { "Tables" },
	ModelName = "HouseBlue",
	ModelScale = nil,
	SurfaceDropFromTop = 0.7,
	ModelOffset = Vector2.new(0, 0),
	ModelRotationDegrees = 90,
	UseImage = true,
	ImageId = "rbxassetid://139987874846868",
	SourceAspect = 1.7768392102936845,
	FitTo = "Width",
	RotationDegrees = 90,
	Scale = Vector2.new(1.1, 1.1),
	Offset = Vector2.new(0, 0),
	ShowGeometryOverlay = true,
	LightInfluence = 0
}

PoolConstants.Rack3D = {
	Enabled = true,
	Offset = Vector2.new(0, -33),
	Height = -4,
	Length = 42,
	Width = 3.6,
	Thickness = 1.2,
	Colour = Color3.fromRGB(10, 12, 14),
	Drop = 2.2,
	Acceleration = 34,
	EntrySpeed = 6,
	Restitution = 0.18,
	SettleSpeed = 1.2,
	Spacing = 1.04,
	ReturnDelay = 0.45,
	ReturnStagger = 0.3
}

PoolConstants.Hud = {
	Panel = Color3.fromRGB(255, 255, 255),
	PanelActive = Color3.fromRGB(255, 255, 255),
	TextPrimary = Color3.fromRGB(232, 237, 235),
	TextMuted = Color3.fromRGB(94, 108, 116),
	EmptyChip = Color3.fromRGB(42, 49, 56),
	Track = Color3.fromRGB(255, 255, 255)
}

PoolConstants.CueBallColour = color9
PoolConstants.AimLineColour = Color3.fromRGB(255, 255, 255)
PoolConstants.HeadStringColour = Color3.fromRGB(255, 255, 255)

function PoolConstants.GetGroup(p: number): string
	if p == PoolConstants.CueBallNumber then
		return "Cue"
	end

	if p == PoolConstants.EightBallNumber then
		return "Eight"
	end

	if p < PoolConstants.EightBallNumber then
		return "Solid"
	end

	return "Stripe"
end

PoolConstants.GoldenBallSkin = 17
PoolConstants.GoldenBallColour = Color3.fromRGB(204, 158, 64)

function PoolConstants.GetTheme(p: string?)
	return PoolConstants.Themes[p or PoolConstants.DefaultTheme] or PoolConstants.Themes.Default
end

function PoolConstants.GetVenue(p: string)
	for _, venue in PoolConstants.Venues do
		if venue.Id == p then
			return venue
		end
	end

	for _, nineBallVenue in PoolConstants.NineBallVenues do
		if nineBallVenue.Id == p then
			return nineBallVenue
		end
	end

	if p == PoolConstants.NineBallVenueId then
		return PoolConstants.NineBallVenue
	end

	return nil
end

function PoolConstants.CallPocketFor(p: string?)
	local v

	if p then
		v = PoolConstants.GetVenue(p)
	end

	local callPocket = v and v.CallPocket

	if callPocket == "Eight" or callPocket == "All" then
		return callPocket
	end

	return nil
end

function PoolConstants.LadderOf(p: string?)
	for _, v in { PoolConstants.Venues, PoolConstants.NineBallVenues } do
		for k, v2 in v do
			if v2.Id == p then
				return v, k
			end
		end
	end

	return nil, nil
end

function PoolConstants.PreviousVenue(p: string?)
	local ladder, v = PoolConstants.LadderOf(p)

	if ladder and v and v > 1 then
		return ladder[v - 1]
	end

	return nil
end

function PoolConstants.TuningVenueId(p: string?)
	local v

	if p then
		v = PoolConstants.GetVenue(p)
	end

	local playsLike = v and v.PlaysLike

	if typeof(playsLike) == "string" and playsLike ~= "" then
		return playsLike
	end

	return p
end

PoolConstants.BotCueLadder = {
	"CueStick1",
	"CueStick2",
	"Arctic Breath",
	"CueStick3",
	"Crimson Dragon",
	"GalaxyCue1",
	"Jungle",
	"Neon",
	"Rainbow Prism",
	"CueStick6",
	"CamoCue",
	"Spooky_T1",
	"CueStick5",
	"CueStick7",
	"CueStick4",
	"Trident",
	"Emerald",
	"CueStick8",
	"Skyfeather",
	"EmeraldFracture",
	"GalaxyCue2",
	"Royal Sapphire",
	"SciFi",
	"Starry",
	"Astra_T2",
	"SpiderCue",
	"Flaming",
	"SilverWebCue",
	"WitchCauldronCue",
	"AmberfallAutumn",
	"BloomcrownSpring",
	"MoonblossomCue",
	"RazorsteelCue",
	"Longblade",
	"Spooky_T2",
	"Astra_T3",
	"GalaxyCue3",
	"AlchemyCue",
	"FrostCrownWinter",
	"GoldenCoreCue",
	"LavaCore",
	"SolsticeSummer",
	"Spooky_T3",
	"RequiemSkullCue",
	"VioletEdgeSwordCue",
	"Astra_T4",
	"DragonSummonerCue",
	"DreadlightPumpkin",
	"GalaxyCue4",
	"WidowWebCue",
	"IroncladCue",
	"Spooky_T4",
	"GalaxyCue5",
	"Astra_T5",
	"SoulreaperScythe",
	"DreadhornHalloweenCue",
	"Spooky_T5"
}

PoolConstants.BotCueRanges = {
	Brazil = { From = 1, To = 12 },
	UnitedStates = { From = 6, To = 17 },
	Indonesia = { From = 9, To = 20 },
	Argentina = { From = 15, To = 26 },
	UnitedKingdom = { From = 19, To = 30 },
	Mexico = { From = 24, To = 35 },
	Canada = { From = 28, To = 39 },
	Philippines = { From = 30, To = 41 },
	Italy = { From = 32, To = 43 },
	Thailand = { From = 38, To = 49 },
	Germany = { From = 40, To = 51 },
	Monaco = { From = 41, To = 52 },
	Greece = { From = 46, To = 57 },
	Turkey = { From = 46, To = 57 },
	Spain = { From = 46, To = 57 },
	NineBall = { From = 9, To = 20 }
}

PoolConstants.BotMenuCueVenue = {
	Beginner = "Brazil",
	Rookie = "UnitedStates",
	Amateur = "Argentina",
	Regular = "Canada",
	Shark = "Monaco",
	Legend = "Greece"
}

function PoolConstants.BotCuesFor(p: string?)
	local botCueRanges = PoolConstants.BotCueRanges
	local tuningVenueId = PoolConstants.TuningVenueId(p)
	local v = p and botCueRanges[p]
		or tuningVenueId and botCueRanges[tuningVenueId]
		or botCueRanges[PoolConstants.Venues[1].Id]
	local botCueLadder = PoolConstants.BotCueLadder
	local result = {}

	if not v then
		return result
	end

	for i = math.max(v.From, 1), math.min(v.To, #botCueLadder) do
		table.insert(result, botCueLadder[i])
	end

	return result
end

function PoolConstants.BotMenuCues(p: string?)
	local botCuesFor = PoolConstants.BotCuesFor
	local v

	if p then
		v = PoolConstants.BotMenuCueVenue[p]
	end

	return botCuesFor(v)
end

function PoolConstants.FirstMatchPrize()
	local venue = PoolConstants.GetVenue(PoolConstants.Tutorial.FirstMatchVenueId)

	return if venue then venue.Prize else 0
end

function PoolConstants.GetCue(p: string?)
	return PoolConstants.Cues[p or PoolConstants.DefaultCue] or PoolConstants.Cues.Starter
end

function PoolConstants.CueEffects(p: string?, p2: number?)
	local result = {}

	for _, v in PoolConstants.CueStatOrder do
		local v2 = PoolConstants.CueStatScale[v]

		local v3 = PoolConstants.CueRating(p, v, p2) / PoolConstants.CueStatMax

		result[v] = v2.Zero + (v2.Ten - v2.Zero) * math.clamp(v3, 0, 1)
	end

	return result
end

function PoolConstants.CueRating(p: string?, p2: string, value: number?)
	return (math.clamp(
		(tonumber(PoolConstants.GetCue(p)[p2]) or 0) + math.max(math.floor(value or 0), 0) * PoolConstants.CueUpgradeStep,
		0,
		PoolConstants.CueStatMax
	))
end

function PoolConstants.RenderedBallDiameter()
	return PoolConstants.BallDiameter * (tonumber(PoolConstants.Ball3D.SizeMultiplier) or 1)
end

PoolConstants.FreeRoamCamera = false

PoolConstants.TableLayout = {
	Solve = { Left = 0, Right = 0, Top = 0, Bottom = 0 },
	Create = { Left = 110, Right = 110, Top = 150, Bottom = 80 }
}

PoolConstants.BareTable = false

PoolConstants.StarsPerPresent = 50

PoolConstants.LevelStarImage = ""
PoolConstants.LevelStarEmptyTint = Color3.fromRGB(70, 80, 104)
PoolConstants.LevelStarEmptyTransparency = 0

PoolConstants.LavaBurn = {
	CharSeconds = 0.35,
	FadeSeconds = 0.6,
	EmberColour = Color3.fromRGB(140, 46, 14),
	CharColour = Color3.fromRGB(16, 12, 10)
}

PoolConstants.TrickshotTable = {
	RimColour = Color3.fromRGB(122, 74, 40),
	RimMaterial = Enum.Material.Wood,
	EdgeColour = Color3.fromRGB(78, 46, 24),
	ClothMaterial = Enum.Material.Fabric,
	CushionMaterial = Enum.Material.Fabric,
	Rivets = true,
	RivetSpacing = 6,
	RivetDiameter = 0.85,
	RivetRise = 0.28,
	RivetColour = Color3.fromRGB(198, 202, 210),
	RivetMaterial = Enum.Material.Metal
}

PoolConstants.LevelThemeBand = 10

PoolConstants.LevelCloths = {
	Color3.fromRGB(150, 45, 48),
	Color3.fromRGB(160, 82, 28),
	Color3.fromRGB(128, 104, 30),
	Color3.fromRGB(38, 124, 68),
	Color3.fromRGB(44, 127, 166),
	Color3.fromRGB(64, 64, 150),
	Color3.fromRGB(110, 54, 142)
}

local v = {}

function PoolConstants.LevelTheme(p: number?)
	local theme = PoolConstants.GetTheme()

	if not p or p < 1 then
		return theme
	end

	local v2 = #PoolConstants.LevelCloths
	local v3 = math.floor((math.floor(p) - 1) / PoolConstants.LevelThemeBand) % v2 + 1

	if v[v3] then
		return v[v3]
	end

	local levelCloth = PoolConstants.LevelCloths[v3]
	local v4 = {
		Cloth = levelCloth,
		Cushion = levelCloth:Lerp(Color3.new(1, 1, 1), 0.12),
		Rail = theme.Rail,
		Frame = theme.Frame,
		Pocket = theme.Pocket,
		PocketCasing = theme.PocketCasing,
		Diamond = theme.Diamond,
		Accent = theme.Accent
	}

	v[v3] = v4

	return v4
end

return PoolConstants