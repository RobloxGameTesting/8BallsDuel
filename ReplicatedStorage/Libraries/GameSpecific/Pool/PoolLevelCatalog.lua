local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolTrickshotTypes = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTrickshotTypes)
local PoolLevelPatterns = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolLevelPatterns)

local Cues = PoolLevelPatterns.Cues
local Golden = PoolLevelPatterns.Golden
local Join = PoolLevelPatterns.Join
local Wall = PoolLevelPatterns.Wall
local Ring = PoolLevelPatterns.Ring
local Cross = PoolLevelPatterns.Cross
local Grid = PoolLevelPatterns.Grid
local Patrol = PoolLevelPatterns.Patrol
local Corridor = PoolLevelPatterns.Corridor

local Spinner = PoolLevelPatterns.Spinner

local Dots = PoolLevelPatterns.Dots
local Loose = PoolLevelPatterns.Loose
local Arc = PoolLevelPatterns.Arc
local Rack = PoolLevelPatterns.Rack
local Hex = PoolLevelPatterns.Hex
local Heart = PoolLevelPatterns.Heart
local Star = PoolLevelPatterns.Star
local Wave = PoolLevelPatterns.Wave
local Spokes = PoolLevelPatterns.Spokes
local Pixels = PoolLevelPatterns.Pixels

local hex = Hex(16, 0, 2, { 10, 1 })
local PoolLevelCatalog = {}

for _, v in hex do
	if v.X > 19 then
		v.N = 12
	end
end

local v = {
	{
		Name = "First Shot",
		Balls = {
			{ N = 0, X = 0, Y = 0 }
		},
		Mods = {
			{ K = "Bullseye", X = 29, Y = 0, S = 0.59 }
		}
	},
	{
		Name = "Event Horizon",
		Balls = {
			{ N = 0, X = 0, Y = 9 },
			{ N = 0, X = 0, Y = 3 },
			{ N = 0, X = 0, Y = -3 }
		},
		Mods = {
			{ K = "Bullseye", X = 29, Y = 0, S = 0.59 },
			{ K = "BlackHole", X = 7, Y = 0, S = 0.5 }
		}
	},
	{
		Name = "Pop Goes the Gold",
		Balls = {
			{ N = 0, X = -32, Y = 0 },
			{ N = 0, X = -32, Y = 12 },
			{
				N = 8,
				X = 8,
				Y = 0,
				A = true,
				S = 2.2
			}
		},
		Mods = {
			{ K = "Bubble", X = 34, Y = 0, S = 0.5 },
			{ K = "Bubble", X = 16, Y = 18, S = 0.5 },
			{ K = "Bubble", X = 16, Y = -18, S = 0.5 }
		}
	},
	{
		Name = "Bubble Boost",
		Balls = {
			{ N = 0, X = -32, Y = -10 },
			{ N = 0, X = -32, Y = 0 }
		},
		Mods = {
			{ K = "Bubble", X = 2, Y = 15, S = 0.6 },
			{ K = "Bubble", X = 22, Y = -13, S = 0.6 },
			{ K = "Bubble", X = 36, Y = 9, S = 0.6 },
			{ K = "Bubble", X = 16, Y = 3, S = 0.6 },
			{ K = "Boost", X = -14, Y = 0, S = 1.2 }
		}
	},
	{
		Name = "The Bends",
		Balls = Join(Cues({
			{ -25, -7 },
			{ -28.25, -10.25 }
		}), Golden({
			{ 24.5, 6.5 }
		}), Corridor({
			{ -29.6, -11.6 },
			{ -7, 11 },
			{ 11, -7 },
			{ 29, 11 }
		}, 3, 1.25, 2.5, 0.9, {
			{ -25, -7 },
			{ -28.25, -10.25 },
			{ 24.5, 6.5 }
		})),
		Mods = {
			{ K = "Pocket", X = 29, Y = 11, S = 2 }
		}
	},
	{
		Name = "Mud Pie",
		Balls = {
			{ N = 0, X = -30, Y = -10 },
			{ N = 0, X = -30, Y = 0 }
		},
		Mods = {
			{ K = "Bullseye", X = 24, Y = 0, S = 0.8 },
			{ K = "Mud", X = 6, Y = 0, S = 1.6 }
		}
	},
	{
		Name = "Sink the Gold",
		Balls = {
			{ N = 0, X = -28, Y = -15 },
			{ N = 0, X = -28, Y = -5 },
			{ N = 0, X = -28, Y = 5 },
			{ N = 12, X = 20, Y = 0 },
			{ N = 12, X = 30, Y = 10 },
			{ N = 12, X = 30, Y = -10 }
		},
		Mods = {
			{ K = "Pocket", X = 38, Y = 18, S = 2 },
			{ K = "Pocket", X = 38, Y = -18, S = 2 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.6 }
		}
	},
	{
		Name = "Gold Rush",
		Balls = {
			{ N = 0, X = -28, Y = -12 },
			{ N = 0, X = -28, Y = 0 },
			{ N = 12, X = 16, Y = 6 },
			{ N = 12, X = 16, Y = -6 },
			{ N = 12, X = 24, Y = 0 }
		},
		Mods = {
			{ K = "Pocket", X = 36, Y = 0, S = 1.6 },
			{
				K = "BlackHole",
				X = 36,
				Y = 0,
				S = 1,
				P = 180
			},
			{ K = "Pocket", X = 0, Y = 19, S = 1.6 },
			{ K = "Pocket", X = 0, Y = -19, S = 1.6 }
		}
	},
	{
		Name = "Tailwind",
		Balls = {
			{ N = 0, X = -30, Y = -12 },
			{ N = 0, X = -30, Y = 0 }
		},
		Mods = {
			{ K = "Bullseye", X = 26, Y = 6, S = 0.75 },
			{
				K = "Fan",
				X = 0,
				Y = -4,
				S = 1.1,
				R = 90
			}
		}
	},
	{
		Name = "Hop Scotch",
		Balls = {
			{ N = 0, X = -32, Y = -10 },
			{ N = 0, X = -32, Y = 0 }
		},
		Mods = {
			{ K = "Lava", X = 0, Y = 0, S = 2.2 },
			{ K = "Trampoline", X = -14, Y = 0, S = 1.4 },
			{ K = "Bubble", X = 20, Y = 0, S = 0.55 },
			{ K = "Bubble", X = 30, Y = 14, S = 0.55 },
			{ K = "Bubble", X = 30, Y = -14, S = 0.55 },
			{ K = "Bubble", X = 0, Y = 17, S = 0.5 }
		}
	},
	{
		Name = "Long Haul",
		TL = 1.5,
		Balls = {
			{ N = 0, X = -50, Y = -10 },
			{ N = 0, X = -50, Y = 0 }
		},
		Mods = {
			{ K = "Bullseye", X = 44, Y = 0, S = 0.8 },
			{
				K = "Boost",
				X = -24,
				Y = 0,
				S = 1.5,
				P = 1.8
			},
			{ K = "Mud", X = 24, Y = 0, S = 1.4 }
		}
	},
	{
		Name = "Moving Target",
		Balls = {
			{ N = 0, X = -32, Y = -10 },
			{ N = 0, X = -32, Y = 0 },
			{
				N = 5,
				X = 4,
				Y = -16,
				RX = 4,
				RY = 16,
				RS = 26
			}
		},
		Mods = {
			{ K = "Bubble", X = 22, Y = 8, S = 0.45 },
			{ K = "Bubble", X = 22, Y = -8, S = 0.45 },
			{ K = "Bubble", X = 36, Y = 0, S = 0.45 }
		}
	},
	{
		Name = "Gravity Assist",
		Balls = {
			{ N = 0, X = -32, Y = -12 },
			{ N = 0, X = -32, Y = 0 }
		},
		Mods = {
			{ K = "Bullseye", X = 26, Y = -6, S = 0.7 },
			{ K = "BlackHole", X = 0, Y = 12, S = 0.9 },
			{ K = "Mud", X = 14, Y = -6, S = 1 }
		}
	},
	{
		Name = "Crosswind",
		Balls = {
			{ N = 0, X = -30, Y = -14 },
			{ N = 0, X = -30, Y = -4 },
			{ N = 0, X = -30, Y = 6 },
			{ N = 12, X = 18, Y = 0 },
			{ N = 12, X = 28, Y = 12 },
			{ N = 12, X = 28, Y = -12 }
		},
		Mods = {
			{ K = "Pocket", X = 38, Y = 18, S = 1.8 },
			{ K = "Pocket", X = 38, Y = -18, S = 1.8 },
			{ K = "Pocket", X = 41, Y = 0, S = 1.5 },
			{
				K = "Fan",
				X = 4,
				Y = 0,
				S = 1.3,
				R = 90,
				P = 140
			}
		}
	},
	{
		Name = "Tight Squeeze",
		TL = 0.6,
		TH = 0.8,
		Balls = {
			{ N = 0, X = -20, Y = -8 },
			{ N = 0, X = -20, Y = 0 }
		},
		Mods = {
			{ K = "Lava", X = 24, Y = 16, S = 1 },
			{ K = "Lava", X = 24, Y = -16, S = 1 },
			{ K = "Lava", X = 8, Y = 0, S = 0.8 },
			{ K = "Lava", X = -6, Y = -15, S = 0.8 },
			{ K = "Bubble", X = 14, Y = 10, S = 0.4 },
			{ K = "Bubble", X = 14, Y = -10, S = 0.4 },
			{ K = "Bubble", X = 22, Y = 0, S = 0.4 },
			{ K = "Bubble", X = -4, Y = 14, S = 0.4 }
		}
	},
	{
		Name = "Lava Lane",
		Balls = {
			{ N = 0, X = -30, Y = -15 },
			{ N = 0, X = -30, Y = -5 },
			{ N = 0, X = -30, Y = 5 },
			{ N = 12, X = 26, Y = 11 },
			{ N = 12, X = 26, Y = -11 },
			{ N = 12, X = 14, Y = 0 }
		},
		Mods = {
			{ K = "Pocket", X = 37, Y = 17, S = 2 },
			{ K = "Pocket", X = 37, Y = -17, S = 2 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.4 },
			{ K = "Lava", X = 28, Y = 3, S = 0.7 },
			{ K = "Lava", X = 4, Y = 17, S = 0.8 },
			{ K = "Lava", X = 4, Y = -17, S = 0.8 }
		}
	},
	{
		Name = "Over the Wall",
		Balls = {
			{ N = 0, X = -32, Y = -10 },
			{ N = 0, X = -32, Y = 0 },
			{
				N = 9,
				X = 10,
				Y = -16,
				A = true,
				S = 2
			},
			{
				N = 9,
				X = 10,
				Y = -8,
				A = true,
				S = 2
			},
			{
				N = 9,
				X = 10,
				Y = 0,
				A = true,
				S = 2
			},
			{
				N = 9,
				X = 10,
				Y = 8,
				A = true,
				S = 2
			},
			{
				N = 9,
				X = 10,
				Y = 16,
				A = true,
				S = 2
			}
		},
		Mods = {
			{ K = "Bullseye", X = 28, Y = 0, S = 0.7 },
			{ K = "Trampoline", X = -6, Y = 0, S = 1.6 },
			{ K = "Trampoline", X = -6, Y = 14, S = 1.2 },
			{ K = "Trampoline", X = -6, Y = -14, S = 1.2 }
		}
	},
	{
		Name = "Rush Hour",
		Balls = {
			{ N = 0, X = -30, Y = -14 },
			{ N = 0, X = -30, Y = -4 },
			{ N = 0, X = -30, Y = 6 },
			{ N = 12, X = 22, Y = 8 },
			{ N = 12, X = 22, Y = -8 },
			{ N = 12, X = 30, Y = 0 },
			{
				N = 5,
				X = 8,
				Y = -18,
				RX = 8,
				RY = 18,
				RS = 30
			}
		},
		Mods = {
			{ K = "Pocket", X = 38, Y = 17, S = 1.7 },
			{ K = "Pocket", X = 38, Y = -17, S = 1.7 },
			{ K = "Pocket", X = 41, Y = 0, S = 1.4 },
			{
				K = "BlackHole",
				X = 38,
				Y = 17,
				S = 0.6,
				P = 150
			}
		}
	},
	{
		Name = "Grand Tour",
		TL = 2,
		TH = 1.5,
		Balls = {
			{ N = 0, X = -70, Y = -16 },
			{ N = 0, X = -70, Y = -5 },
			{ N = 0, X = -70, Y = 5 }
		},
		Mods = {
			{ K = "Boost", X = -48, Y = 0, S = 1.6 },
			{
				K = "Fan",
				X = -10,
				Y = 10,
				S = 1.4,
				R = 0,
				P = 260
			},
			{
				K = "Fan",
				X = 30,
				Y = -10,
				S = 1.4,
				R = 180,
				P = 260
			},
			{ K = "Bubble", X = -20, Y = -24, S = 0.4 },
			{ K = "Bubble", X = 10, Y = 26, S = 0.4 },
			{ K = "Bubble", X = 46, Y = 12, S = 0.4 },
			{ K = "Bubble", X = 70, Y = -20, S = 0.4 },
			{ K = "Mud", X = 20, Y = 0, S = 1.5 },
			{ K = "Lava", X = 58, Y = 0, S = 1.4 },
			{ K = "Lava", X = -20, Y = 10, S = 1 },
			{ K = "Lava", X = 10, Y = -14, S = 1 },
			{ K = "BlackHole", X = 40, Y = 26, S = 0.7 }
		}
	},
	{
		Name = "Hot Target",
		Balls = {
			{ N = 0, X = -32, Y = -10 },
			{ N = 0, X = -32, Y = 0 }
		},
		Mods = {
			{ K = "Bullseye", X = 26, Y = 0, S = 0.7 },
			{ K = "Lava", X = 26, Y = 17, S = 0.8 },
			{ K = "Lava", X = 26, Y = -17, S = 0.8 },
			{
				K = "Fan",
				X = -2,
				Y = -8,
				S = 0.9,
				R = 90,
				P = 60
			},
			{ K = "Lava", X = 6, Y = 14, S = 0.6 }
		}
	},
	{
		Name = "Gold Standard",
		Balls = {
			{ N = 0, X = -34, Y = -15 },
			{ N = 0, X = -34, Y = -5 },
			{ N = 0, X = -34, Y = 5 },
			{ N = 0, X = -34, Y = 15 },
			{ N = 12, X = 10, Y = 14 },
			{ N = 12, X = 10, Y = -14 },
			{ N = 12, X = 26, Y = 6 },
			{ N = 12, X = 26, Y = -6 },
			{
				N = 5,
				X = -6,
				Y = -18,
				RX = -6,
				RY = 18,
				RS = 24
			}
		},
		Mods = {
			{ K = "Pocket", X = 0, Y = 20, S = 1.9 },
			{ K = "Pocket", X = 0, Y = -20, S = 1.9 },
			{ K = "Pocket", X = 40, Y = 16, S = 1.9 },
			{ K = "Pocket", X = 40, Y = -16, S = 1.9 },
			{ K = "Pocket", X = 42, Y = 0, S = 1.4 },
			{ K = "Lava", X = 30, Y = 19, S = 0.7 },
			{ K = "Lava", X = 30, Y = -19, S = 0.7 },
			{
				K = "BlackHole",
				X = 18,
				Y = 0,
				S = 0.6,
				P = 120
			},
			{
				K = "Fan",
				X = -18,
				Y = 0,
				S = 0.9,
				R = 0,
				P = 90
			}
		}
	},
	{
		Name = "Picket Fence",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Wall(6, -20, 6, 20, 9, 1.4, { 2, 4, 6, 8 })),
		Mods = {
			{ K = "Bullseye", X = 28, Y = 0, S = 0.9 }
		}
	},
	{
		Name = "Bubble Garden",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Cross(-8, 0, 2, 3.5, 1.2), Cross(18, 0, 2, 3.5, 1.2)),
		Mods = {
			{ K = "Bubble", X = 5, Y = 12, S = 0.6 },
			{ K = "Bubble", X = 5, Y = -12, S = 0.6 },
			{ K = "Bubble", X = 32, Y = 10, S = 0.6 },
			{ K = "Bubble", X = 32, Y = -10, S = 0.6 }
		}
	},
	{
		Name = "Leapfrog",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Wall(6, -22, 6, 22, 9, 2)),
		Mods = {
			{ K = "Trampoline", X = -10, Y = 0, S = 1.5 },
			{ K = "Trampoline", X = -10, Y = 14, S = 1.1 },
			{ K = "Trampoline", X = -10, Y = -14, S = 1.1 },
			{ K = "Bubble", X = 20, Y = 10, S = 0.45 },
			{ K = "Bubble", X = 20, Y = -10, S = 0.45 },
			{ K = "Bubble", X = 36, Y = 0, S = 0.45 }
		}
	},
	{
		Name = "Slingshot",
		Balls = Cues({
			{ -32, -10 },
			{ -32, 0 }
		}),
		Mods = {
			{ K = "Bullseye", X = 26, Y = -10, S = 0.7 },
			{
				K = "BlackHole",
				X = 8,
				Y = 10,
				S = 0.8,
				P = 260
			},
			{ K = "Boost", X = -14, Y = 6, S = 1.2 },
			{ K = "Mud", X = 36, Y = -10, S = 1 }
		}
	},
	{
		Name = "Carousel",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Patrol(10, -18, 10, 18, 30), Patrol(26, 18, 26, -18, 30), Patrol(18, -18, 18, 18, 18)),
		Mods = {
			{ K = "Bubble", X = 14, Y = 0, S = 0.5 },
			{ K = "Bubble", X = 30, Y = 10, S = 0.5 },
			{ K = "Bubble", X = 30, Y = -10, S = 0.5 },
			{ K = "Bubble", X = 40, Y = 0, S = 0.5 }
		}
	},
	{
		Name = "Fortress",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Ring(22, 0, 13, 16, 1.6, 180, 80)),
		Mods = {
			{ K = "Bullseye", X = 22, Y = 0, S = 0.5 }
		}
	},
	{
		Name = "Hourglass",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Wall(-4, -22, 8, -4, 6, 1.5), Wall(-4, 22, 8, 4, 6, 1.5)),
		Mods = {
			{ K = "Bubble", X = 20, Y = 0, S = 0.5 },
			{ K = "Bubble", X = 34, Y = 12, S = 0.5 },
			{ K = "Bubble", X = 34, Y = -12, S = 0.5 },
			{ K = "Bubble", X = -18, Y = 16, S = 0.5 }
		}
	},
	{
		Name = "Conveyor",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Ring(6, 0, 6, 10, 1.6, 0, 0)),
		Mods = {
			{
				K = "Fan",
				X = 6,
				Y = 14,
				S = 0.8,
				R = 0,
				P = 220
			},
			{
				K = "Fan",
				X = 6,
				Y = -14,
				S = 0.8,
				R = 0,
				P = 220
			},
			{ K = "Bubble", X = 30, Y = 14, S = 0.5 },
			{ K = "Bubble", X = 30, Y = -14, S = 0.5 },
			{ K = "Bubble", X = 24, Y = 0, S = 0.5 },
			{ K = "Bubble", X = 40, Y = 0, S = 0.5 }
		}
	},
	{
		Name = "Pendulums",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Patrol(-4, -18, -4, 18, 18), Patrol(4, 18, 4, -18, 22), Patrol(12, -18, 12, 18, 26), Patrol(20, 18, 20, -18, 30), Patrol(28, -18, 28, 18, 34)),
		Mods = {
			{ K = "Bubble", X = 38, Y = 12, S = 0.55 },
			{ K = "Bubble", X = 38, Y = -12, S = 0.55 },
			{ K = "Bubble", X = 40, Y = 0, S = 0.55 }
		}
	},
	{
		Name = "Crossroads",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Cross(-12, 6, 2, 3.5, 1), Cross(10, -6, 2, 3.5, 1), Cross(30, 6, 2, 3.5, 1)),
		Mods = {
			{ K = "Bubble", X = -1, Y = 15, S = 0.55 },
			{ K = "Bubble", X = -1, Y = -12, S = 0.55 },
			{ K = "Bubble", X = 20, Y = 15, S = 0.55 },
			{ K = "Bubble", X = 38, Y = -12, S = 0.55 }
		}
	},
	{
		Name = "Gatekeepers",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Wall(8, -22, 8, -5, 4, 2), Wall(8, 22, 8, 5, 4, 2), Patrol(14, -10, 14, 10, 20), Patrol(22, 10, 22, -10, 28)),
		Mods = {
			{ K = "Bubble", X = 32, Y = 8, S = 0.55 },
			{ K = "Bubble", X = 32, Y = -8, S = 0.55 },
			{ K = "Bubble", X = 38, Y = 0, S = 0.55 },
			{ K = "Bubble", X = -6, Y = 16, S = 0.55 }
		}
	},
	{
		Name = "Checkerboard",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Grid(10, 0, 5, 3, 9, 1.3)),
		Mods = {
			{ K = "Bubble", X = 5.5, Y = 4.5, S = 0.45 },
			{ K = "Bubble", X = 14.5, Y = -4.5, S = 0.45 },
			{ K = "Bubble", X = 23.5, Y = 4.5, S = 0.45 },
			{ K = "Bubble", X = -3.5, Y = -4.5, S = 0.45 }
		}
	},
	{
		Name = "Zigzag",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Wall(-6, -22, -6, -6, 4, 1.8), Wall(12, 22, 12, 6, 4, 1.8)),
		Mods = {
			{ K = "Bullseye", X = 30, Y = 0, S = 0.65 }
		}
	},
	{
		Name = "Slalom",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Wall(-14, -8, -14, 8, 3, 1.5), Wall(0, -22, 0, -10, 3, 1.5), Wall(0, 22, 0, 10, 3, 1.5), Wall(14, -8, 14, 8, 3, 1.5)),
		Mods = {
			{ K = "Bubble", X = -7, Y = 14, S = 0.5 },
			{ K = "Bubble", X = 7, Y = 0, S = 0.5 },
			{ K = "Bubble", X = 21, Y = 14, S = 0.5 },
			{ K = "Bubble", X = 30, Y = -8, S = 0.5 }
		}
	},
	{
		Name = "The Corridor",
		TL = 1.5,
		TH = 0.6,
		Balls = Join(Cues({
			{ -58, -8 },
			{ -58, -3 },
			{ -58, 3 }
		}), Patrol(-10, -11, -10, 11, 24), Patrol(20, 11, 20, -11, 30)),
		Mods = {
			{ K = "Bullseye", X = 46, Y = 0, S = 0.6 },
			{ K = "Mud", X = 34, Y = 0, S = 1.1 }
		}
	},
	{
		Name = "Tempest",
		Balls = Cues({
			{ -32, -10 },
			{ -32, 0 }
		}),
		Mods = {
			{
				K = "Fan",
				X = -12,
				Y = 10,
				S = 1.2,
				R = 270,
				P = 320
			},
			{
				K = "Fan",
				X = 4,
				Y = -10,
				S = 1.2,
				R = 90,
				P = 320
			},
			{
				K = "Fan",
				X = 20,
				Y = 10,
				S = 1.2,
				R = 270,
				P = 320
			},
			{ K = "Lava", X = 4, Y = 10, S = 0.9 },
			{ K = "Lava", X = 20, Y = -10, S = 0.9 },
			{ K = "Bubble", X = 12, Y = 18, S = 0.4 },
			{ K = "Bubble", X = 12, Y = -18, S = 0.4 },
			{ K = "Bubble", X = 38, Y = 0, S = 0.4 },
			{ K = "Bubble", X = -20, Y = -17, S = 0.4 }
		}
	},
	{
		Name = "Traffic",
		Balls = Join(Cues({
			{ -32, -15 },
			{ -32, -5 },
			{ -32, 5 }
		}), Golden({
			{ 30, 10 },
			{ 30, -10 },
			{ 34, 0 }
		}), Patrol(0, -20, 0, 20, 20), Patrol(10, 20, 10, -20, 28), Patrol(20, -20, 20, 20, 36)),
		Mods = {
			{ K = "Pocket", X = 39, Y = 18, S = 2 },
			{ K = "Pocket", X = 39, Y = -18, S = 2 },
			{ K = "Pocket", X = 42, Y = 0, S = 1.7 }
		}
	},
	{
		Name = "Labyrinth",
		TL = 1.5,
		Balls = Join(Cues({
			{ -56, -16 },
			{ -56, -8 },
			{ -56, 0 },
			{ -56, 8 }
		}), Wall(-36, -22, -36, 2, 6, 1.6), Wall(-8, 22, -8, -2, 6, 1.6), Wall(20, -22, 20, 2, 6, 1.6)),
		Mods = {
			{ K = "Bubble", X = -22, Y = 14, S = 0.7 },
			{ K = "Bubble", X = 6, Y = -14, S = 0.7 },
			{ K = "Bubble", X = 36, Y = 14, S = 0.7 }
		}
	},
	{
		Name = "Event Horizon II",
		Balls = Join(Cues({
			{ -32, -15 },
			{ -32, -5 },
			{ -32, 5 }
		}), Golden({
			{ 4, 12 },
			{ 4, -12 },
			{ 22, 0 }
		})),
		Mods = {
			{ K = "Pocket", X = 38, Y = 16, S = 1.8 },
			{ K = "Pocket", X = 38, Y = -16, S = 1.8 },
			{
				K = "BlackHole",
				X = 38,
				Y = 16,
				S = 0.7,
				P = 300
			},
			{
				K = "BlackHole",
				X = 38,
				Y = -16,
				S = 0.7,
				P = 300
			},
			{
				K = "BlackHole",
				X = 12,
				Y = 0,
				S = 0.9,
				P = 200
			}
		}
	},
	{
		Name = "Needle's Eye",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Wall(4, -22, 4, 22, 11, 1.5, { 6 })),
		Mods = {
			{ K = "Bullseye", X = 28, Y = 0, S = 0.7 }
		}
	},
	{
		Name = "Chaos Theory",
		Balls = Join(Cues({
			{ -32, -15 },
			{ -32, -5 },
			{ -32, 5 }
		}), Patrol(2, -18, 2, 18, 26), Cross(18, 10, 1, 3.5, 1), Cross(18, -10, 1, 3.5, 1)),
		Mods = {
			{
				K = "Fan",
				X = -14,
				Y = 0,
				S = 1.1,
				R = 90,
				P = 180
			},
			{
				K = "BlackHole",
				X = 30,
				Y = 0,
				S = 0.8,
				P = 240
			},
			{ K = "Lava", X = 8, Y = 0, S = 0.8 },
			{ K = "Trampoline", X = -22, Y = 0, S = 1.3 },
			{ K = "Bubble", X = 8, Y = 17, S = 0.45 },
			{ K = "Bubble", X = 8, Y = -17, S = 0.45 },
			{ K = "Bubble", X = 38, Y = 12, S = 0.45 },
			{ K = "Bubble", X = 38, Y = -12, S = 0.45 }
		}
	},
	{
		Name = "Pinball",
		Balls = Join(Cues({
			{ -32, -15 },
			{ -32, -5 },
			{ -32, 5 }
		}), Golden({
			{ 28, 12 },
			{ 28, -12 },
			{ 32, 0 }
		}), {
			{
				N = 8,
				X = 4,
				Y = 11,
				S = 3,
				A = true
			},
			{
				N = 8,
				X = 4,
				Y = -11,
				S = 3,
				A = true
			},
			{
				N = 8,
				X = -12,
				Y = 0,
				S = 2.5,
				A = true
			}
		}),
		Mods = {
			{ K = "Pocket", X = 39, Y = 18, S = 2 },
			{ K = "Pocket", X = 39, Y = -18, S = 2 },
			{ K = "Pocket", X = 42, Y = 0, S = 1.7 }
		}
	},
	{
		Name = "The Vault",
		Balls = Join(Cues({
			{ -32, -15 },
			{ -32, -5 },
			{ -32, 5 }
		}), Golden({
			{ 20, 0 },
			{ 26, 7 },
			{ 26, -7 }
		}), Ring(23, 0, 13, 12, 1.5, 180, 110)),
		Mods = {
			{ K = "Pocket", X = -14, Y = 18, S = 1.9 },
			{ K = "Pocket", X = -14, Y = -18, S = 1.9 },
			{ K = "Pocket", X = 42, Y = 0, S = 1.7 }
		}
	},
	{
		Name = "Grand Maze",
		TL = 1.5,
		TH = 1.2,
		Balls = Join(Cues({
			{ -58, -18 },
			{ -58, -6 },
			{ -58, 6 }
		}), Wall(-38, -26, -38, -2, 5, 1.7), Wall(-14, 26, -14, 2, 5, 1.7), Wall(10, -26, 10, -2, 5, 1.7), Wall(34, 26, 34, 2, 5, 1.7)),
		Mods = {
			{
				K = "Boost",
				X = -48,
				Y = 0,
				S = 1.6,
				P = 2.2
			},
			{ K = "Bubble", X = -26, Y = 16, S = 0.8 },
			{ K = "Bubble", X = -2, Y = -16, S = 0.8 },
			{ K = "Bubble", X = 22, Y = 16, S = 0.8 },
			{ K = "Bubble", X = 50, Y = -12, S = 0.8 }
		}
	},
	{
		Name = "The Gauntlet",
		TL = 1.5,
		TH = 0.7,
		Balls = Join(Cues({
			{ -58, -9 },
			{ -58, -3 },
			{ -58, 3 }
		}), Cross(-30, 7, 1, 4, 1.1), Cross(0, -7, 1, 4, 1.1), Cross(30, 7, 1, 4, 1.1), Patrol(-15, -13, -15, 13, 22), Patrol(15, 13, 15, -13, 28)),
		Mods = {
			{ K = "Bullseye", X = 50, Y = 0, S = 0.65 },
			{
				K = "Boost",
				X = -44,
				Y = 0,
				S = 1.3,
				P = 1.6
			}
		}
	},
	{
		Name = "Spiral",
		Balls = Join(Cues({
			{ -32, -10 },
			{ -32, 0 }
		}), Ring(20, 0, 17, 20, 1.3, 180, 80), Ring(20, 0, 9, 10, 1.2, 0, 110)),
		Mods = {
			{ K = "Bullseye", X = 20, Y = 0, S = 0.35 },
			{ K = "Mud", X = 20, Y = 0, S = 0.8 }
		}
	},
	{
		Name = "Double Cross",
		Balls = Join(Cues({
			{ -32, -15 },
			{ -32, -5 },
			{ -32, 5 }
		}), Golden({
			{ 20, 14 },
			{ 20, -14 },
			{ 30, 0 }
		}), Cross(-4, 0, 2, 3.5, 1), Cross(16, 0, 1, 3.5, 1)),
		Mods = {
			{ K = "Pocket", X = 36, Y = 18, S = 2 },
			{ K = "Pocket", X = 36, Y = -18, S = 2 },
			{ K = "Pocket", X = 42, Y = 0, S = 1.8 }
		}
	},
	{
		Name = "Minefield",
		Balls = Join(Cues({
			{ -32, -15 },
			{ -32, -5 },
			{ -32, 5 }
		}), Golden({
			{ 24, 10 },
			{ 24, -10 },
			{ 30, 0 }
		}), Grid(4, 0, 2, 3, 12, 1.4)),
		Mods = {
			{ K = "Pocket", X = 39, Y = 18, S = 1.9 },
			{ K = "Pocket", X = 39, Y = -18, S = 1.9 },
			{ K = "Pocket", X = 42, Y = 0, S = 1.6 },
			{ K = "Lava", X = -10, Y = 16, S = 0.7 },
			{ K = "Lava", X = -10, Y = -16, S = 0.7 },
			{ K = "Lava", X = 16, Y = 0, S = 0.5 }
		}
	},
	{
		Name = "The Long Game",
		TL = 1.8,
		TH = 1.3,
		Balls = Join(Cues({
			{ -66, -20 },
			{ -66, -10 },
			{ -66, 0 },
			{ -66, 10 }
		}), Golden({
			{ -10, 18 },
			{ -10, -18 },
			{ 26, 10 },
			{ 26, -10 }
		}), Wall(6, -28, 6, -6, 4, 1.8), Wall(6, 28, 6, 6, 4, 1.8)),
		Mods = {
			{
				K = "Boost",
				X = -48,
				Y = 0,
				S = 1.6,
				P = 2
			},
			{ K = "Pocket", X = -34, Y = 26, S = 1.9 },
			{ K = "Pocket", X = -34, Y = -26, S = 1.9 },
			{ K = "Pocket", X = 56, Y = 20, S = 1.9 },
			{ K = "Pocket", X = 56, Y = -20, S = 1.9 },
			{ K = "Pocket", X = 62, Y = 0, S = 1.6 }
		}
	},
	{
		Name = "Grand Finale",
		TL = 1.2,
		Balls = Join(Cues({
			{ -46, -16 },
			{ -46, -8 },
			{ -46, 0 },
			{ -46, 8 }
		}), Wall(-20, -22, -20, -4, 3, 1.7), Wall(-20, 22, -20, 4, 3, 1.7), Patrol(2, -20, 2, 20, 28), Cross(24, 15, 1, 3.5, 1), Cross(24, -15, 1, 3.5, 1)),
		Mods = {
			{ K = "Bullseye", X = 38, Y = 0, S = 0.78 },
			{
				K = "Fan",
				X = 12,
				Y = 0,
				S = 1,
				R = 90,
				P = 110
			},
			{ K = "Lava", X = 38, Y = 21, S = 0.7 },
			{ K = "Lava", X = 38, Y = -21, S = 0.7 },
			{
				K = "Boost",
				X = -34,
				Y = 0,
				S = 1.4,
				P = 1.8
			}
		}
	},
	{
		Name = "First Turn",
		Balls = Join(Cues({
			{ -32, -12 },
			{ -32, -4 },
			{ -32, 4 }
		}), Spinner(0, 0, 3, 1, 70, 1)),
		Mods = {
			{ K = "Bullseye", X = 30, Y = 0, S = 0.55 }
		}
	},
	{
		Name = "Windmill",
		Balls = Join(Cues({
			{ -34, -12 },
			{ -34, -4 },
			{ -34, 4 }
		}), Spinner(2, 0, 5, 1, 145, 1)),
		Mods = {
			{ K = "Bubble", X = 30, Y = 15, S = 0.65 },
			{ K = "Bubble", X = 30, Y = -15, S = 0.65 },
			{ K = "Bubble", X = 38, Y = 0, S = 0.65 }
		}
	},
	{
		Name = "Twin Fans",
		Balls = Join(Cues({
			{ -34, -14 },
			{ -34, 0 }
		}), Golden({
			{ 4, 12 },
			{ 4, -12 },
			{ 14, 0 }
		}), Spinner(-12, 13, 3, 1, 130, 1), Spinner(-12, -13, 3, 1, -130, 2)),
		Mods = {
			{ K = "Pocket", X = 36, Y = 15, S = 2 },
			{ K = "Pocket", X = 36, Y = -15, S = 2 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.8 }
		}
	},
	{
		Name = "Paddle Wheel",
		TL = 1.2,
		Balls = Join(Cues({
			{ -46, -12 },
			{ -46, -4 },
			{ -46, 4 }
		}), Spinner(-8, 0, 8, 1, 130, 1)),
		Mods = {
			{ K = "Bullseye", X = 38, Y = 0, S = 0.45 }
		}
	},
	{
		Name = "Clockwork",
		TL = 1.2,
		Balls = Join(Cues({
			{ -48, -14 },
			{ -48, -5 },
			{ -48, 5 }
		}), Wall(-22, -22, -22, 22, 7, 1.6, { 4 }), Spinner(2, 0, 4, 2, 150, 1), Patrol(26, -18, 26, 18, 26)),
		Mods = {
			{ K = "Bubble", X = 44, Y = 13, S = 0.8 },
			{ K = "Bubble", X = 44, Y = -13, S = 0.8 },
			{ K = "Bubble", X = 50, Y = 0, S = 0.8 },
			{ K = "Bubble", X = 14, Y = 19, S = 0.8 }
		}
	},
	{
		Name = "Carousel",
		Balls = Join(Cues({
			{ -34, -10 },
			{ -34, 0 }
		}), Golden({
			{ 8, 9 },
			{ 8, -9 },
			{ 18, 0 }
		}), Ring(10, 0, 19, 18, 1.2, 180, 60), Spinner(10, 0, 2, 2, 70, 1)),
		Mods = {
			{ K = "Pocket", X = 10, Y = 14, S = 1.8 },
			{ K = "Pocket", X = 10, Y = -14, S = 1.8 },
			{ K = "Pocket", X = 24, Y = 0, S = 1.8 }
		}
	},
	{
		Name = "Turnstile",
		TL = 1.3,
		TH = 0.75,
		Balls = Join(Cues({
			{ -52, -10 },
			{ -52, -3 },
			{ -52, 4 }
		}), Wall(-8, -16, -8, -9, 3, 1.5), Wall(-8, 16, -8, 9, 3, 1.5), Spinner(-8, 0, 2, 1, 170, 1)),
		Mods = {
			{ K = "Bullseye", X = 40, Y = 0, S = 0.55 },
			{ K = "Mud", X = 40, Y = 0, S = 0.9 },
			{
				K = "Boost",
				X = -36,
				Y = 0,
				S = 1.2,
				P = 1.4
			}
		}
	},
	{
		Name = "Eggbeater",
		TL = 1.3,
		TH = 0.8,
		Balls = Join(Cues({
			{ -50, -11 },
			{ -50, -4 },
			{ -50, 3 }
		}), Spinner(-14, 5, 4, 2, 150, 1), Spinner(2, -5, 4, 2, -170, 2), Spinner(18, 5, 4, 2, 190, 3)),
		Mods = {
			{ K = "Bubble", X = 44, Y = 13, S = 0.65 },
			{ K = "Bubble", X = 44, Y = -13, S = 0.65 },
			{ K = "Bubble", X = 52, Y = 0, S = 0.65 },
			{ K = "Bubble", X = 2, Y = 15, S = 0.65 }
		}
	},
	{
		Name = "The Mixer",
		Balls = Join(Cues({
			{ -36, -12 },
			{ -36, 0 }
		}), Golden({
			{ -8, 11 },
			{ -8, -11 },
			{ 0, 0 }
		}), Spinner(16, 0, 3, 3, 120, 1)),
		Mods = {
			{ K = "BlackHole", X = 16, Y = 0, S = 1.1 },
			{ K = "Pocket", X = 38, Y = 15, S = 1.9 },
			{ K = "Pocket", X = 38, Y = -15, S = 1.9 },
			{ K = "Pocket", X = 42, Y = 0, S = 1.7 }
		}
	},
	{
		Name = "Ferris Wheel",
		TL = 1.2,
		Balls = Join(Cues({
			{ -48, -14 },
			{ -48, -5 },
			{ -48, 5 }
		}), Spinner(-6, 0, 8, 2, 50, 1)),
		Mods = {
			{ K = "Bullseye", X = 40, Y = 0, S = 0.5 },
			{
				K = "Boost",
				X = -34,
				Y = 0,
				S = 1.4,
				P = 1.6
			}
		}
	},
	{
		Name = "Labyrinth",
		TL = 1.4,
		TH = 1.2,
		Balls = Join(Cues({
			{ -56, -16 },
			{ -56, -5 },
			{ -56, 6 }
		}), Wall(-26, -26, -26, 4, 5, 1.4), Wall(4, 26, 4, -4, 5, 1.4)),
		Mods = {
			{ K = "Bullseye", X = 46, Y = -14, S = 0.5 },
			{ K = "Mud", X = 46, Y = -14, S = 1.8 },
			{
				K = "Boost",
				X = -44,
				Y = 0,
				S = 1.5,
				P = 1.6
			}
		}
	},
	{
		Name = "Pinwheel Alley",
		TL = 1.5,
		TH = 0.8,
		Balls = Join(Cues({
			{ -62, -11 },
			{ -62, -4 },
			{ -62, 3 }
		}), Spinner(-30, 6, 3, 1, 160, 1), Spinner(-6, -6, 3, 1, -180, 2), Spinner(18, 6, 3, 1, 200, 3)),
		Mods = {
			{ K = "Bubble", X = 46, Y = 13, S = 0.6 },
			{ K = "Bubble", X = 46, Y = -13, S = 0.6 },
			{ K = "Bubble", X = 58, Y = 0, S = 0.6 },
			{ K = "Bubble", X = 32, Y = 15, S = 0.6 }
		}
	},
	{
		Name = "Threadneedle",
		TL = 1.3,
		Balls = Join(Cues({
			{ -50, -13 },
			{ -50, -4 },
			{ -50, 5 }
		}), Golden({
			{ 20, 12 },
			{ 20, -12 },
			{ 28, 0 }
		}), Grid(-10, 0, 3, 4, 11, 1.3), Spinner(10, 0, 3, 1, 140, 1)),
		Mods = {
			{ K = "Pocket", X = 48, Y = 16, S = 1.9 },
			{ K = "Pocket", X = 48, Y = -16, S = 1.9 },
			{ K = "Pocket", X = 52, Y = 0, S = 1.7 }
		}
	},
	{
		Name = "The Press",
		TL = 1.2,
		Balls = Join(Cues({
			{ -48, -12 },
			{ -48, -4 },
			{ -48, 4 }
		}), Spinner(0, 16, 6, 1, 120, 1), Spinner(0, -16, 6, 1, -120, 2)),
		Mods = {
			{ K = "Bullseye", X = 40, Y = 0, S = 0.45 }
		}
	},
	{
		Name = "Orbit",
		TL = 1.2,
		Balls = Join(Cues({
			{ -48, -12 },
			{ -48, 0 }
		}), Golden({
			{ -6, 16 },
			{ -6, -16 },
			{ 26, 10 },
			{ 26, -10 }
		}), Spinner(10, 0, 2, 2, 90, 1)),
		Mods = {
			{ K = "BlackHole", X = 10, Y = 0, S = 0.85 },
			{ K = "Pocket", X = 10, Y = 12, S = 2 },
			{ K = "Pocket", X = 10, Y = -12, S = 2 },
			{ K = "Pocket", X = 22, Y = 0, S = 2 },
			{ K = "Pocket", X = -2, Y = 0, S = 2 }
		}
	},
	{
		Name = "Rapids",
		TL = 1.5,
		TH = 0.9,
		Balls = Join(Cues({
			{ -62, -12 },
			{ -62, -4 },
			{ -62, 4 }
		}), Wall(-42, -20, -42, 20, 7, 1.5, { 2 }), Patrol(-24, -18, -24, 18, 30), Patrol(6, 18, 6, -18, 34), Spinner(-9, 0, 3, 1, 170, 1)),
		Mods = {
			{
				K = "Boost",
				X = -46,
				Y = 0,
				S = 1.5,
				P = 1.8
			},
			{
				K = "Boost",
				X = 22,
				Y = 0,
				S = 1.4,
				P = 1.4
			},
			{ K = "Bubble", X = 50, Y = 15, S = 0.5 },
			{ K = "Bubble", X = 50, Y = -15, S = 0.5 },
			{ K = "Bubble", X = 60, Y = 0, S = 0.5 },
			{ K = "Bubble", X = 30, Y = 17, S = 0.5 }
		}
	},
	{
		Name = "Switchback",
		TL = 1.4,
		TH = 1.1,
		Balls = Join(Cues({
			{ -56, -14 },
			{ -56, -5 },
			{ -56, 5 }
		}), Wall(-34, -24, -6, -24, 6, 1.5), Wall(-20, 24, 8, 24, 6, 1.5), Wall(-6, -24, -6, -2, 5, 1.5), Wall(8, 24, 8, 2, 5, 1.5), Wall(22, -24, 22, -2, 5, 1.5)),
		Mods = {
			{ K = "Bubble", X = 40, Y = 19, S = 0.55 },
			{ K = "Bubble", X = 40, Y = -19, S = 0.55 },
			{ K = "Bubble", X = 54, Y = 0, S = 0.55 },
			{ K = "Bubble", X = 0, Y = 12, S = 0.55 }
		}
	},
	{
		Name = "Gearbox",
		TL = 1.3,
		Balls = Join(Cues({
			{ -50, -13 },
			{ -50, -4 },
			{ -50, 5 }
		}), Spinner(-14, 10, 4, 1, 110, 1), Spinner(2, -10, 3, 1, -150, 2), Spinner(16, 10, 2, 2, 200, 3)),
		Mods = {
			{ K = "Bullseye", X = 44, Y = 0, S = 0.5 },
			{ K = "Mud", X = 44, Y = 0, S = 1.8 }
		}
	},
	{
		Name = "The Vault",
		TL = 1.2,
		Balls = Join(Cues({
			{ -48, -10 },
			{ -48, 0 }
		}), Golden({
			{ 16, 7 },
			{ 16, -7 },
			{ 24, 0 }
		}), Ring(18, 0, 18, 18, 1.2, 180, 55), Spinner(0, 0, 3, 1, 150, 1)),
		Mods = {
			{ K = "Pocket", X = 18, Y = 13, S = 1.8 },
			{ K = "Pocket", X = 18, Y = -13, S = 1.8 },
			{ K = "Pocket", X = 30, Y = 0, S = 1.7 }
		}
	},
	{
		Name = "Tempest",
		TL = 1.3,
		Balls = Join(Cues({
			{ -52, -13 },
			{ -52, -4 },
			{ -52, 5 }
		}), Spinner(-6, 0, 5, 2, 160, 1)),
		Mods = {
			{ K = "Bullseye", X = 42, Y = 0, S = 0.45 },
			{
				K = "Fan",
				X = 20,
				Y = 16,
				S = 1.2,
				R = 270,
				P = 120
			},
			{
				K = "Fan",
				X = 20,
				Y = -16,
				S = 1.2,
				R = 90,
				P = 120
			},
			{ K = "Lava", X = 42, Y = 18, S = 0.8 },
			{ K = "Lava", X = 42, Y = -18, S = 0.8 }
		}
	},
	{
		Name = "Needlepoint",
		TL = 1.4,
		TH = 0.8,
		Balls = Join(Cues({
			{ -58, -11 },
			{ -58, -4 },
			{ -58, 3 }
		}), Wall(-20, -17, -20, -6, 4, 1.4), Wall(-20, 17, -20, 6, 4, 1.4), Wall(8, -17, 8, -6, 4, 1.4), Wall(8, 17, 8, 6, 4, 1.4)),
		Mods = {
			{ K = "Bullseye", X = 44, Y = 0, S = 0.42 },
			{ K = "Mud", X = 44, Y = 0, S = 2 },
			{
				K = "Boost",
				X = -42,
				Y = 0,
				S = 1.3,
				P = 1.3
			}
		}
	},
	{
		Name = "Clockwork Maze",
		TL = 1.5,
		TH = 1.2,
		Balls = Join(Cues({
			{ -62, -16 },
			{ -62, -5 },
			{ -62, 6 }
		}), Wall(-34, -26, -34, 6, 6, 1.6), Wall(-10, 26, -10, -6, 6, 1.6), Spinner(14, 0, 4, 2, 150, 1), Wall(38, -26, 38, 6, 6, 1.6)),
		Mods = {
			{ K = "Bubble", X = 56, Y = 18, S = 0.8 },
			{ K = "Bubble", X = 56, Y = -18, S = 0.8 },
			{ K = "Bubble", X = 26, Y = 20, S = 0.8 },
			{ K = "Bubble", X = 2, Y = -20, S = 0.8 }
		}
	},
	{
		Name = "Crosswinds",
		TL = 1.4,
		Balls = Join(Cues({
			{ -56, -12 },
			{ -56, 0 }
		}), Golden({
			{ -16, 12 },
			{ -16, -12 },
			{ -6, 0 }
		}), Spinner(14, 0, 4, 4, 130, 1)),
		Mods = {
			{
				K = "Fan",
				X = 0,
				Y = 14,
				S = 1.3,
				R = 270,
				P = 130
			},
			{
				K = "Fan",
				X = 0,
				Y = -14,
				S = 1.3,
				R = 90,
				P = 130
			},
			{ K = "Pocket", X = 52, Y = 17, S = 1.9 },
			{ K = "Pocket", X = 52, Y = -17, S = 1.9 },
			{ K = "Pocket", X = 56, Y = 0, S = 1.7 }
		}
	},
	{
		Name = "The Sieve",
		TL = 1.4,
		TH = 1.1,
		Balls = Join(Cues({
			{ -56, -14 },
			{ -56, -5 },
			{ -56, 5 }
		}), Grid(-6, 0, 4, 5, 10, 1.2)),
		Mods = {
			{ K = "Bubble", X = 44, Y = 18, S = 0.8 },
			{ K = "Bubble", X = 44, Y = -18, S = 0.8 },
			{ K = "Bubble", X = 54, Y = 0, S = 0.8 },
			{ K = "Bubble", X = 20, Y = 0, S = 0.8 }
		}
	},
	{
		Name = "Double Helix",
		TL = 1.5,
		TH = 1.2,
		Balls = Join(Cues({
			{ -62, -14 },
			{ -62, -4 },
			{ -62, 6 }
		}), Golden({
			{ -14, 14 },
			{ -14, -14 },
			{ 22, 8 },
			{ 22, -8 }
		}), Ring(-14, 0, 11, 12, 1.2, 180, 90), Spinner(24, 0, 3, 2, 140, 1), Spinner(-40, 0, 2, 2, -170, 2)),
		Mods = {
			{ K = "Pocket", X = 10, Y = 24, S = 1.1 },
			{ K = "Pocket", X = 10, Y = -24, S = 1.1 },
			{ K = "Pocket", X = 48, Y = 20, S = 1.2 },
			{ K = "Pocket", X = 48, Y = -20, S = 1.2 }
		}
	},
	{
		Name = "Hurricane",
		TL = 1.3,
		Balls = Join(Cues({
			{ -52, -13 },
			{ -52, -4 },
			{ -52, 5 }
		}), Spinner(0, 0, 7, 2, 120, 1)),
		Mods = {
			{ K = "Bullseye", X = 44, Y = 0, S = 0.4 },
			{ K = "BlackHole", X = 0, Y = 0, S = 1.2 },
			{
				K = "Boost",
				X = -38,
				Y = 0,
				S = 1.4,
				P = 2
			}
		}
	},
	{
		Name = "The Crucible",
		TL = 1.4,
		Balls = Join(Cues({
			{ -56, -12 },
			{ -56, -4 },
			{ -56, 4 }
		}), Wall(-24, -20, -24, -4, 4, 1.5), Wall(-24, 20, -24, 4, 4, 1.5), Spinner(6, 0, 3, 1, 180, 1)),
		Mods = {
			{ K = "Bubble", X = 46, Y = 14, S = 0.75 },
			{ K = "Bubble", X = 46, Y = -14, S = 0.75 },
			{ K = "Bubble", X = 54, Y = 0, S = 0.75 },
			{ K = "Bubble", X = 24, Y = 18, S = 0.75 },
			{ K = "Lava", X = 30, Y = 0, S = 0.9 },
			{ K = "Lava", X = -6, Y = 18, S = 0.8 },
			{ K = "Lava", X = -6, Y = -18, S = 0.8 }
		}
	},
	{
		Name = "Precision",
		TL = 1.7,
		TH = 0.7,
		Balls = Join(Cues({
			{ -70, -10 },
			{ -70, -3 },
			{ -70, 4 }
		}), Cross(-30, 9, 1, 4, 1.1), Cross(-30, -9, 1, 4, 1.1), Cross(0, 9, 1, 4, 1.1), Cross(0, -9, 1, 4, 1.1), Cross(30, 9, 1, 4, 1.1), Cross(30, -9, 1, 4, 1.1)),
		Mods = {
			{ K = "Bullseye", X = 60, Y = 0, S = 0.4 },
			{ K = "Mud", X = 60, Y = 0, S = 2.2 },
			{
				K = "Boost",
				X = -56,
				Y = 0,
				S = 1.4,
				P = 1.4
			}
		}
	},
	{
		Name = "The Long Way Round",
		TL = 1.9,
		TH = 1.4,
		Balls = Join(Cues({
			{ -76, -22 },
			{ -76, -8 },
			{ -76, 6 }
		}), Golden({
			{ -20, 22 },
			{ -20, -22 },
			{ 30, 14 },
			{ 30, -14 }
		}), Wall(4, -30, 4, -6, 5, 1.8), Wall(4, 30, 4, 6, 5, 1.8), Spinner(-46, 0, 4, 2, 100, 1)),
		Mods = {
			{
				K = "Boost",
				X = -62,
				Y = 0,
				S = 1.6,
				P = 2.2
			},
			{ K = "Pocket", X = -4, Y = 28, S = 2 },
			{ K = "Pocket", X = -4, Y = -28, S = 2 },
			{ K = "Pocket", X = 44, Y = 20, S = 2 },
			{ K = "Pocket", X = 44, Y = -20, S = 2 },
			{ K = "Pocket", X = 76, Y = 0, S = 1.6 }
		}
	},
	{
		Name = "Apex",
		TL = 1.5,
		TH = 1.2,
		Balls = Join(Cues({
			{ -62, -18 },
			{ -62, -9 },
			{ -62, 0 },
			{ -62, 9 }
		}), Wall(-34, -26, -34, -7, 4, 1.7), Wall(-34, 26, -34, 7, 4, 1.7), Spinner(-6, 0, 6, 2, 110, 1), Spinner(24, 16, 3, 1, -190, 2), Spinner(24, -16, 3, 1, 190, 3)),
		Mods = {
			{ K = "Bullseye", X = 52, Y = 0, S = 0.45 },
			{ K = "Mud", X = 52, Y = 0, S = 2 },
			{
				K = "Fan",
				X = 10,
				Y = 0,
				S = 1.1,
				R = 90,
				P = 120
			},
			{ K = "Lava", X = 52, Y = 22, S = 0.8 },
			{
				K = "Boost",
				X = -50,
				Y = 0,
				S = 1.5,
				P = 1.6
			}
		}
	},
	{
		Name = "Say Cheese",
		Balls = Join(Cues({
			{ -36, -8 },
			{ -36, 0 },
			{ -36, 8 }
		}), Ring(14, 0, 17, 22, 1.2, 180, 80, 1), Arc(14, -1, 9, 215, 325, 6, 1.1, 3)),
		Mods = {
			{ K = "Bubble", X = 9, Y = 6, S = 0.6 },
			{ K = "Bubble", X = 19, Y = 6, S = 0.6 },
			{ K = "Bubble", X = -14, Y = 16, S = 0.6 },
			{ K = "Bubble", X = -14, Y = -16, S = 0.6 }
		}
	},
	{
		Name = "Strike!",
		Balls = Join(Cues({
			{ -36, -4 },
			{ -36, 4 },
			{ -36, 0 }
		}), Rack(12, 0, 4, {
			1,
			12,
			12,
			6,
			2,
			7,
			12,
			10,
			3,
			12
		}, 6), Wall(-30, 13, 4, 13, 9, 1, nil, 7), Wall(-30, -13, 4, -13, 9, 1, nil, 7)),
		Mods = {
			{
				K = "Boost",
				X = -18,
				Y = 0,
				S = 1.1,
				P = 1.6
			},
			{ K = "Pocket", X = 39, Y = 12, S = 2 },
			{ K = "Pocket", X = 39, Y = -12, S = 2 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.8 },
			{ K = "Pocket", X = 27, Y = 19, S = 1.8 },
			{ K = "Pocket", X = 27, Y = -19, S = 1.8 }
		}
	},
	{
		Name = "Bounce House",
		Balls = Join(Cues({
			{ -38, -10 },
			{ -38, 0 },
			{ -38, 10 }
		}), Wall(-14, -20, -14, 20, 10, 1.4, { 8 }, 2), Wall(6, -20, 6, 20, 10, 1.4, { 3 }, 3), Wall(24, -20, 24, 20, 10, 1.4, { 6 }, 6)),
		Mods = {
			{ K = "Trampoline", X = -22, Y = -2, S = 1.3 },
			{ K = "Trampoline", X = -2, Y = 6, S = 1.3 },
			{ K = "Trampoline", X = 16, Y = -6, S = 1.3 },
			{ K = "Bubble", X = -14, Y = 11.11, S = 0.5 },
			{ K = "Bubble", X = 6, Y = -11.11, S = 0.5 },
			{ K = "Bubble", X = 24, Y = 2.22, S = 0.5 },
			{ K = "Bubble", X = 36, Y = 12, S = 0.7 }
		}
	},
	{
		Name = "Heartbreaker",
		Balls = Join(Cues({
			{ -36, -8 },
			{ -36, 0 },
			{ -36, 8 }
		}), Heart(14, 0, 32, 28, 1.2, 3, { 20, 21, 22, 23 }), Golden({
			{ 8, 4 },
			{ 20, 4 },
			{ -14, -13 }
		})),
		Mods = {
			{ K = "Pocket", X = 14, Y = -7, S = 1.6 },
			{ K = "Pocket", X = 25, Y = 6, S = 1.3 },
			{ K = "Pocket", X = -4, Y = -18, S = 1.6 }
		}
	},
	{
		Name = "Loop the Loop",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Ring(2, 9.5, 6, 11, 1.3, 0, 0, 2)),
		Mods = {
			{ K = "Bullseye", X = 34, Y = 0, S = 0.6 },
			{
				K = "Mud",
				X = 34,
				Y = 0,
				S = 1.6,
				P = 28
			},
			{
				K = "Boost",
				X = -14,
				Y = 14,
				S = 1,
				P = 1.5
			},
			{
				K = "Boost",
				X = 14,
				Y = 14,
				S = 1,
				P = 1.5
			},
			{
				K = "Boost",
				X = -14,
				Y = -14,
				S = 1,
				P = 1.5
			},
			{
				K = "Boost",
				X = 14,
				Y = -14,
				S = 1,
				P = 1.5
			}
		}
	},
	{
		Name = "Quicksand",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 }
		}), Cross(-2, 9, 1, 3, 1.2, 6), Cross(-14, 12, 1, 3, 1.1, 14), Cross(-14, -12, 1, 3, 1.1, 14), Cross(38, 15, 1, 3, 1.1, 6), Cross(38, -15, 1, 3, 1.1, 6)),
		Mods = {
			{ K = "Bullseye", X = 22, Y = 0, S = 0.55 },
			{
				K = "Mud",
				X = 22,
				Y = 0,
				S = 1.3,
				P = 30
			},
			{
				K = "BlackHole",
				X = 26,
				Y = 0,
				S = 0.6,
				P = 85
			}
		}
	},
	{
		Name = "Newton's Cradle",
		Balls = Join(Cues({
			{ -36, 9 },
			{ -36, -9 },
			{ -36, 0 }
		}), Loose({
			{ -16, 9 },
			{ -13.7, 9 },
			{ -11.4, 9 },
			{ -9.1, 9 }
		}, 2), Golden({
			{ -6.8, 9 }
		}), Loose({
			{ -16, -9 },
			{ -13.7, -9 },
			{ -11.4, -9 },
			{ -9.1, -9 }
		}, 3), Golden({
			{ -6.8, -9 }
		}), Patrol(6, -18, 6, 18, 22, 1.5)),
		Mods = {
			{ K = "Pocket", X = 24, Y = 9, S = 1.5 },
			{ K = "Pocket", X = 24, Y = -9, S = 1.5 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.3 }
		}
	},
	{
		Name = "Shooting Star",
		Balls = Join(Cues({
			{ -38, -10 },
			{ -38, 0 },
			{ -38, 10 }
		}), Star(16, 0, 13, 5.5, 5, 3, 1, 1, 90)),
		Mods = {
			{ K = "Bubble", X = 16, Y = 17.5, S = 0.6 },
			{ K = "Bubble", X = -0.7, Y = 5.4, S = 0.6 },
			{ K = "Bubble", X = 5.7, Y = -14.2, S = 0.6 },
			{ K = "Bubble", X = 26.3, Y = -14.2, S = 0.6 },
			{ K = "Bubble", X = 32.7, Y = 5.4, S = 0.6 },
			{
				K = "Boost",
				X = -14,
				Y = 2,
				S = 1,
				P = 1.4
			},
			{
				K = "Boost",
				X = -24,
				Y = 1,
				S = 0.8,
				P = 1.3
			}
		}
	},
	{
		Name = "Sandstorm",
		Balls = Join(Cues({
			{ -38, -10 },
			{ -38, 0 },
			{ -38, 10 }
		}), Wave(-30, 40, 19, 1.5, 14, 14, 0.9, 13), Wave(-30, 40, -19, 1.5, 14, 14, 0.9, 13, 180)),
		Mods = {
			{
				K = "Fan",
				X = -8,
				Y = 0,
				S = 1.1,
				R = 0,
				P = 110
			},
			{
				K = "Fan",
				X = 16,
				Y = 0,
				S = 1.1,
				R = 0,
				P = 110
			},
			{ K = "Bubble", X = 2, Y = 13, S = 0.5 },
			{ K = "Bubble", X = 18, Y = -13, S = 0.5 },
			{ K = "Bubble", X = 32, Y = 9, S = 0.5 },
			{ K = "Bubble", X = 38, Y = -9, S = 0.5 }
		}
	},
	{
		Name = "Pinball Wizard",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 },
			{ -38, 16 }
		}), Dots({
			{ 0, 9, 3 },
			{ 0, -9, 3 },
			{ 14, 5.5, 2 },
			{ 22, 12, 11 },
			{ 22, -12, 11 }
		}, 2.4), Golden({
			{ 8, 16 },
			{ 8, -16 },
			{ 30, 0 }
		})),
		Mods = {
			{
				K = "Boost",
				X = -14,
				Y = 0,
				S = 1,
				P = 1.5
			},
			{ K = "Pocket", X = 40, Y = 0, S = 1.8 },
			{ K = "Pocket", X = 40, Y = 17, S = 1.8 },
			{ K = "Pocket", X = 40, Y = -17, S = 1.8 },
			{ K = "Pocket", X = 16, Y = 19, S = 1.7 },
			{ K = "Pocket", X = 16, Y = -19, S = 1.7 }
		}
	},
	{
		Name = "Camel Crossing",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 }
		}), Patrol(-10, -18, -10, 18, 22, 1.6), Patrol(4, 18, 4, -18, 26, 1.6), Patrol(18, -18, 18, 18, 30, 1.6), Cross(36, 0, 1, 3, 1.1, 6)),
		Mods = {
			{ K = "Bubble", X = -3, Y = 10, S = 0.6 },
			{ K = "Bubble", X = 11, Y = -10, S = 0.6 },
			{ K = "Bubble", X = 30, Y = 12, S = 0.6 },
			{ K = "Bubble", X = 30, Y = -12, S = 0.6 }
		}
	},
	{
		Name = "Paddle Boat",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 },
			{ -38, 12 }
		}), Spinner(8, 0, 2, 1, 45, 1), Golden({
			{ 22, 9 },
			{ 22, -9 },
			{ 0, 14 }
		})),
		Mods = {
			{ K = "Pocket", X = 32, Y = 13, S = 2 },
			{ K = "Pocket", X = 32, Y = -13, S = 2 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.8 },
			{ K = "Pocket", X = 11, Y = 18.5, S = 1.8 }
		}
	},
	{
		Name = "Sidewinder",
		Balls = Join(Cues({
			{ -38, -12 },
			{ -38, -4 },
			{ -38, 4 }
		}), Wave(-22, 30, 0, 6, 26, 24, 1.1, 6), Dots({
			{ 33.5, 0, 14 }
		}, 1.8)),
		Mods = {
			{ K = "Trampoline", X = -8, Y = -11, S = 1.2 },
			{ K = "Bubble", X = -2.5, Y = 12, S = 0.6 },
			{ K = "Bubble", X = 23.5, Y = 12, S = 0.6 },
			{ K = "Bubble", X = -15.5, Y = -12, S = 0.6 },
			{ K = "Bubble", X = 10.5, Y = -12, S = 0.6 },
			{ K = "Bubble", X = 38, Y = -14, S = 0.6 }
		}
	},
	{
		Name = "Lift Off",
		Balls = Join(Cues({
			{ -16, 0 },
			{ -38, 18 },
			{ -38, -18 }
		}), Wall(-20, 5, 4, 5, 8, 1.1, nil, 11), Wall(-20, -5, 4, -5, 8, 1.1, nil, 11), Dots({
			{ 7, 3.4 },
			{ 7, -3.4 },
			{ -23, 7.5 },
			{ -25.5, 10 },
			{ -23, -7.5 },
			{ -25.5, -10 }
		}, 1.1, 11), Dots({
			{ -6, 17 },
			{ 20, -17 },
			{ 26, 17 },
			{ -30, -17 },
			{ 4, -17 }
		}, 0.7, 1)),
		Mods = {
			{
				K = "Boost",
				X = -10,
				Y = 0,
				S = 0.9,
				P = 1.15
			},
			{
				K = "Boost",
				X = 0,
				Y = 0,
				S = 0.9,
				P = 1.15
			},
			{ K = "Bullseye", X = 32, Y = 0, S = 0.7 },
			{
				K = "Mud",
				X = 32,
				Y = 0,
				S = 2.4,
				P = 40
			}
		}
	},
	{
		Name = "Pyramid Heist",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Wall(2, -16, 2, 16, 9, 1.2, { 4, 5, 6 }, 13), Wall(2, 16, 30, 0, 9, 1.2, { 1 }, 13), Wall(2, -16, 30, 0, 9, 1.2, {
			1,
			9
		}, 13), Golden({
			{ 10, 0 },
			{ 14, 7 }
		})),
		Mods = {
			{ K = "Pocket", X = 21, Y = 0, S = 1.9 },
			{ K = "Pocket", X = 11, Y = -8, S = 1.7 },
			{ K = "Trampoline", X = -8, Y = 12, S = 1.2 }
		}
	},
	{
		Name = "Oasis",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 }
		}), Cross(2, 12, 1, 3, 1.1, 6), Cross(2, -12, 1, 3, 1.1, 6), Cross(34, 14, 1, 3, 1.1, 6), Cross(34, -14, 1, 3, 1.1, 6)),
		Mods = {
			{ K = "Bullseye", X = 18, Y = 0, S = 0.56 },
			{
				K = "Mud",
				X = 18,
				Y = 0,
				S = 1.6,
				P = 28
			},
			{
				K = "Mud",
				X = -14,
				Y = 0,
				S = 0.9,
				P = 12
			},
			{ K = "Lava", X = 18, Y = 17, S = 0.6 },
			{ K = "Lava", X = 18, Y = -17, S = 0.6 }
		}
	},
	{
		Name = "Mirage",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 }
		}), Cross(36, 16, 1, 3, 1, 6), Cross(36, -16, 1, 3, 1, 6)),
		Mods = {
			{
				K = "BlackHole",
				X = 6,
				Y = 0,
				S = 1,
				P = 260
			},
			{ K = "Bubble", X = 18, Y = 12, S = 0.6 },
			{ K = "Bubble", X = 26, Y = 0, S = 0.6 },
			{ K = "Bubble", X = 18, Y = -12, S = 0.6 },
			{ K = "Bubble", X = -6, Y = 14, S = 0.6 }
		}
	},
	{
		Name = "Domino Run",
		Balls = Join(Cues({
			{ -32.3, -18.9 },
			{ -38, 12 },
			{ -38, 18 },
			{ -38, 4 }
		}), Loose({
			{ -26, -14, 8 },
			{ -22.06, -10.92, 1 },
			{ -18.12, -7.84, 8 },
			{ -14.18, -4.76, 1 },
			{ -10.24, -1.68, 8 },
			{ -6.3, 1.4, 1 }
		}), Golden({
			{ -2.36, 4.48 },
			{ 18, 2 }
		})),
		Mods = {
			{ K = "Pocket", X = 9.5, Y = 13.7, S = 1.7 },
			{ K = "Pocket", X = 32, Y = 6, S = 1.7 },
			{ K = "Pocket", X = 32, Y = -14, S = 1.5 }
		}
	},
	{
		Name = "Century",
		Balls = Join(Cues({
			{ -38, -14 },
			{ -38, -6 },
			{ -38, 2 },
			{ -38, 7 }
		}), Wall(-26, 10, -26, 20, 5, 0.8, nil, 1), Dots({
			{ -28, 18.2 }
		}, 0.8, 1), Ring(0, 7, 10, 18, 1.2, 180, 70, 3), Ring(26, -7, 10, 18, 1.2, 180, 70, 2)),
		Mods = {
			{ K = "Bubble", X = 0, Y = 7, S = 0.95 },
			{ K = "Bubble", X = 26, Y = -7, S = 0.95 },
			{ K = "Bubble", X = -12, Y = -15, S = 0.6 },
			{ K = "Bubble", X = 13.5, Y = 16, S = 0.8 },
			{ K = "Trampoline", X = 6, Y = -12, S = 1 }
		}
	},
	{
		Name = "Snow Globe",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Ring(16, 0, 16, 24, 1.2, 180, 60, 10), Wall(8, -19.8, 24, -19.8, 5, 1.2, nil, 7)),
		Mods = {
			{
				K = "Fan",
				X = 16,
				Y = 8,
				S = 0.7,
				R = 180,
				P = 90
			},
			{
				K = "Fan",
				X = 16,
				Y = -8,
				S = 0.7,
				R = 0,
				P = 90
			},
			{ K = "Bubble", X = 9, Y = 8.5, S = 0.55 },
			{ K = "Bubble", X = 23, Y = 8.5, S = 0.55 },
			{ K = "Bubble", X = 9, Y = -8.5, S = 0.55 },
			{ K = "Bubble", X = 23, Y = -8.5, S = 0.55 }
		}
	},
	{
		Name = "Snowflake",
		Balls = Join(Cues({
			{ -38, -9 },
			{ -38, -3 },
			{ -38, 3 },
			{ -38, 9 }
		}), Spokes(16, 0, 6, 2, 3.6, 1.1, 10, 0)),
		Mods = {
			{ K = "Bubble", X = 26.83, Y = 6.25, S = 0.55 },
			{ K = "Bubble", X = 16, Y = 12.5, S = 0.55 },
			{ K = "Bubble", X = 5.17, Y = 6.25, S = 0.55 },
			{ K = "Bubble", X = 5.17, Y = -6.25, S = 0.55 },
			{ K = "Bubble", X = 16, Y = -12.5, S = 0.55 },
			{ K = "Bubble", X = 26.83, Y = -6.25, S = 0.55 }
		}
	},
	{
		Name = "Ice Rink",
		TL = 1.6,
		Balls = Join(Cues({
			{ -62, -6 },
			{ -62, 0 },
			{ -62, 6 }
		}), Patrol(20, -16, 20, 16, 18, 2.2), Arc(50, 0, 13, -70, 70, 7, 1.2, 2)),
		Mods = {
			{
				K = "Boost",
				X = -36,
				Y = 0,
				S = 1,
				P = 1.5
			},
			{ K = "Bullseye", X = 40, Y = 0, S = 0.55 },
			{
				K = "BlackHole",
				X = 40,
				Y = 0,
				S = 1,
				P = 70
			}
		}
	},
	{
		Name = "Snowball",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), hex),
		Mods = {
			{ K = "Pocket", X = 34, Y = 9, S = 1.8 },
			{ K = "Pocket", X = 34, Y = -9, S = 1.8 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.6 },
			{ K = "Pocket", X = 26, Y = 17, S = 1.4 },
			{ K = "Pocket", X = 26, Y = -17, S = 1.4 }
		}
	},
	{
		Name = "Avalanche",
		Balls = Join(Cues({
			{ -38, 10 },
			{ -38, 2 },
			{ -38, -6 }
		}), Rack(4, 12, 4, {
			10,
			12,
			13,
			10,
			12,
			10,
			13,
			10,
			12,
			13
		})),
		Mods = {
			{
				K = "Fan",
				X = 2,
				Y = 6,
				S = 1,
				R = 270,
				P = 140
			},
			{ K = "Pocket", X = -4, Y = -17, S = 1.8 },
			{ K = "Pocket", X = 9, Y = -17, S = 1.8 },
			{ K = "Pocket", X = 22, Y = -17, S = 1.8 },
			{ K = "Pocket", X = 35, Y = -17, S = 1.8 }
		}
	},
	{
		Name = "Igloo",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Ring(18, 0, 13, 20, 1.2, 180, 40, 10), Wall(-3, 4.6, 5, 4.6, 4, 1.1, nil, 10), Wall(-3, -4.6, 5, -4.6, 4, 1.1, nil, 10)),
		Mods = {
			{ K = "Bubble", X = 14, Y = 6, S = 0.6 },
			{ K = "Bubble", X = 24, Y = 5, S = 0.6 },
			{ K = "Bubble", X = 19, Y = -7, S = 0.6 },
			{ K = "Bubble", X = 18, Y = 18, S = 0.6 },
			{ K = "Trampoline", X = 2, Y = 14, S = 1.2 }
		}
	},
	{
		Name = "Sled Run",
		Balls = Join(Cues({
			{ -28, -14.5 },
			{ -28, -11.5 },
			{ -28, -8.5 }
		}), Corridor({
			{ -32, -11.5 },
			{ 4, -11.5 },
			{ 4, 11 },
			{ 33, 11 }
		}, 5.5, 1.5, 3.5, 2.9, {
			{ -28, -14.5 },
			{ -28, -11.5 },
			{ -28, -8.5 }
		}, 10)),
		Mods = {
			{
				K = "Boost",
				X = 4,
				Y = 0,
				S = 0.9,
				P = 1.3
			},
			{ K = "Bullseye", X = 25, Y = 11, S = 0.36 },
			{
				K = "Mud",
				X = 25,
				Y = 11,
				S = 1.2,
				P = 32
			}
		}
	},
	{
		Name = "Penguin Slide",
		Balls = Join(Cues({
			{ -38, 10 },
			{ -38, -10 },
			{ -38, 0 }
		}), {
			{ N = 12, X = -8, Y = 10, S = 1.4 },
			{ N = 12, X = -8, Y = -10, S = 1.4 }
		}, Dots({
			{ -8, 0, 10 },
			{ 22, 0, 10 }
		}, 2.2)),
		Mods = {
			{
				K = "Fan",
				X = 12,
				Y = 10,
				S = 0.9,
				R = 0,
				P = 120
			},
			{
				K = "Fan",
				X = 12,
				Y = -10,
				S = 0.9,
				R = 0,
				P = 120
			},
			{ K = "Pocket", X = 34, Y = 11, S = 1.9 },
			{ K = "Pocket", X = 34, Y = -11, S = 1.9 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.6 }
		}
	},
	{
		Name = "Thin Ice",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Dots({
			{ -20, 16 },
			{ -20, -16 }
		}, 1.2, 10)),
		Mods = {
			{ K = "Lava", X = 0, Y = 9, S = 0.7 },
			{ K = "Lava", X = 0, Y = -9, S = 0.7 },
			{ K = "Lava", X = 18, Y = 0, S = 0.8 },
			{ K = "Lava", X = 34, Y = 12, S = 0.6 },
			{ K = "Lava", X = 34, Y = -12, S = 0.6 },
			{ K = "Bubble", X = 8, Y = 0, S = 0.6 },
			{ K = "Bubble", X = 18, Y = 12, S = 0.6 },
			{ K = "Bubble", X = 18, Y = -12, S = 0.6 },
			{ K = "Bubble", X = 36, Y = 0, S = 0.6 }
		}
	},
	{
		Name = "Northern Lights",
		Balls = Join(Cues({
			{ -38, -14 },
			{ -38, -6 },
			{ -38, 2 }
		}), Patrol(-6, -8, 30, -8, 20, 1.3), Patrol(30, 17, -6, 17, 24, 1.3)),
		Mods = {
			{ K = "Bubble", X = 30, Y = 5.2, S = 0.55 },
			{ K = "Bubble", X = 21.3, Y = 8.8, S = 0.55 },
			{ K = "Bubble", X = 12, Y = 10, S = 0.55 },
			{ K = "Bubble", X = 2.7, Y = 8.8, S = 0.55 },
			{ K = "Bubble", X = -6, Y = 5.2, S = 0.55 }
		}
	},
	{
		Name = "Yeti",
		Balls = Join(Cues({
			{ -22, -8 },
			{ -22, 8 },
			{ -22, 0 },
			{ -22, 14 }
		}), Dots({
			{ 8, 0 }
		}, 3.5, 10), Dots({
			{ 0, 17 },
			{ 0, -17 },
			{ 16, 18 },
			{ 16, -18 }
		}, 1, 2), {
			{ N = 12, X = 20, Y = 8, S = 1.3 },
			{ N = 12, X = 20, Y = -8, S = 1.3 },
			{ N = 12, X = 18, Y = 0, S = 1.3 }
		}),
		Mods = {
			{ K = "Pocket", X = 34, Y = 8, S = 1.8 },
			{ K = "Pocket", X = 34, Y = -8, S = 1.8 },
			{ K = "Pocket", X = 40, Y = 0, S = 1.4 }
		}
	},
	{
		Name = "Pong",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Patrol(24, -14, 24, 14, 24, 2.4), Dots({
			{ 0, 18 },
			{ 0, 10 },
			{ 0, -10 },
			{ 0, -18 }
		}, 0.7, 1)),
		Mods = {
			{ K = "Bullseye", X = 37, Y = 0, S = 0.5 },
			{
				K = "Mud",
				X = 37,
				Y = 0,
				S = 1.7,
				P = 30
			}
		}
	},
	{
		Name = "Space Invaders",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 }
		}), Pixels(
			{
				"..X.....X..",
				"...X...X...",
				"..XXXXXXX..",
				".XX.XXX.XX.",
				"XXXXXXXXXXX",
				"X.XXXXXXX.X",
				"X.X.....X.X",
				"...XX.XX..."
			},
			14,
			4,
			2.3,
			0.9,
			6
		), Patrol(-6, -17, 30, -17, 20, 1.4)),
		Mods = {
			{ K = "Bubble", X = 34, Y = 12, S = 0.6 },
			{ K = "Bubble", X = 34, Y = -6, S = 0.6 },
			{ K = "Bubble", X = 14, Y = -10, S = 0.6 },
			{ K = "Bubble", X = -6, Y = 14, S = 0.6 }
		}
	},
	{
		Name = "Pac-Man",
		Balls = Join(Cues({
			{ -9, 0 },
			{ -5, 3.5 },
			{ -5, -3.5 }
		}), Ring(-6, 0, 9, 18, 1.3, 0, 70, 1), Wall(8, 7, 36, 7, 8, 1, { 2, 6 }, 2), Wall(8, -7, 36, -7, 8, 1, { 2, 6 }, 2), Patrol(28, -16, 28, 16, 24, 1.6)),
		Mods = {
			{ K = "Bubble", X = 12, Y = 0, S = 0.45 },
			{ K = "Bubble", X = 22, Y = 0, S = 0.45 },
			{ K = "Bubble", X = 34, Y = 0, S = 0.45 },
			{ K = "Bubble", X = 38, Y = 16, S = 0.7 }
		}
	},
	{
		Name = "Claw Machine",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Wall(4, -16, 36, -16, 9, 1.2, nil, 7), Wall(4, 16, 36, 16, 9, 1.2, nil, 7), Wall(36, -12, 36, 12, 7, 1.2, nil, 7), Spinner(24, 6, 2, 1, 70, 1), Golden({
			{ 16, 0 },
			{ 26, -6 },
			{ 12, -9 }
		})),
		Mods = {
			{ K = "Pocket", X = 31, Y = -11, S = 1.4 },
			{ K = "Pocket", X = 31, Y = 11, S = 1.4 }
		}
	},
	{
		Name = "Skee-Ball",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Ring(30, 0, 9, 18, 1.1, 0, 50, 3), Wall(-30, 11, 14, 11, 10, 1, nil, 7), Wall(-30, -11, 14, -11, 10, 1, nil, 7)),
		Mods = {
			{ K = "Trampoline", X = 10, Y = 0, S = 1.6 },
			{ K = "Bullseye", X = 30, Y = 0, S = 0.37 },
			{
				K = "Mud",
				X = 30,
				Y = 0,
				S = 1,
				P = 42
			}
		}
	},
	{
		Name = "Mini Golf",
		Balls = Join(Cues({
			{ -36, -11 },
			{ -36, 11 },
			{ -36, -6 }
		}), Wall(-26, 0, 38, 0, 16, 1.1, nil, 6), Spinner(14, 15.5, 2, 1, 70, 1), Arc(31, 11, 9.6, -55, 55, 5, 1.1, 6), Arc(31, -11, 9.6, -55, 55, 5, 1.1, 6)),
		Mods = {
			{ K = "Bullseye", X = 31, Y = 11, S = 0.4 },
			{
				K = "BlackHole",
				X = 31,
				Y = 11,
				S = 0.75,
				P = 95
			},
			{
				K = "Mud",
				X = 31,
				Y = 11,
				S = 1.4,
				P = 32
			},
			{ K = "Bullseye", X = 31, Y = -11, S = 0.4 },
			{
				K = "BlackHole",
				X = 31,
				Y = -11,
				S = 0.75,
				P = 95
			},
			{
				K = "Mud",
				X = 31,
				Y = -11,
				S = 1.4,
				P = 32
			},
			{ K = "Lava", X = 10, Y = -17.5, S = 0.65 },
			{ K = "Lava", X = 18, Y = -4.5, S = 0.5 }
		}
	},
	{
		Name = "Air Hockey",
		Balls = Join(Cues({
			{ 12, 4 },
			{ 12, -4 },
			{ 8, 0 }
		}), {
			{ N = 12, X = 24, Y = 4, S = 1.2 },
			{ N = 12, X = 24, Y = -4, S = 1.2 }
		}, Patrol(34, -9, 34, 9, 18, 1.5), Dots({
			{ 41, 9 },
			{ 41, -9 },
			{ -41, 9 },
			{ -41, -9 }
		}, 1.2, 3)),
		Mods = {
			{ K = "Pocket", X = 41, Y = 0, S = 2 },
			{ K = "Pocket", X = -41, Y = 0, S = 2 }
		}
	},
	{
		Name = "Plinko",
		Balls = Join(Cues({
			{ -38, 16 },
			{ -38, 8 },
			{ -38, 0 }
		}), Rack(14, 16, 5, { 9, 1, 9, 1, 9 }, 6, 270, true, 0.9)),
		Mods = {
			{
				K = "Fan",
				X = 14,
				Y = 20,
				S = 1.8,
				R = 270,
				P = 70
			},
			{ K = "Bubble", X = -2, Y = -17, S = 0.6 },
			{ K = "Bubble", X = 8, Y = -17, S = 0.6 },
			{ K = "Bubble", X = 18, Y = -17, S = 0.6 },
			{ K = "Bubble", X = 28, Y = -17, S = 0.6 }
		}
	},
	{
		Name = "Jackpot",
		Balls = Join(Cues({
			{ -38, 0 },
			{ -38, 12 },
			{ -38, -12 },
			{ -38, 6 }
		}), Spinner(10, 6, 2, 1, 100, 1), Spinner(10, -6, 2, 1, -110, 2), {
			{ N = 12, X = 27, Y = 12, S = 1.4 },
			{ N = 12, X = 27, Y = 0, S = 1.4 },
			{ N = 12, X = 27, Y = -12, S = 1.4 }
		}),
		Mods = {
			{ K = "Pocket", X = 35, Y = 12, S = 2 },
			{ K = "Pocket", X = 35, Y = 0, S = 2 },
			{ K = "Pocket", X = 35, Y = -12, S = 2 }
		}
	},
	{
		Name = "Breakout",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Loose({
			{ 13, -9, 3 },
			{ 13, -6.7, 13 },
			{ 13, -4.4, 1 },
			{ 13, -2.1, 6 },
			{ 13, 0.2, 2 },
			{ 13, 2.5, 3 },
			{ 13, 4.8, 13 },
			{ 13, 7.1, 1 },
			{ 13, 9.4, 6 }
		}), Wall(13, 12, 13, 20.5, 4, 1.1, nil, 8), Wall(13, -11.5, 13, -20.5, 4, 1.1, nil, 8), Patrol(-24, -14, -24, 14, 20, 2)),
		Mods = {
			{ K = "Trampoline", X = 2, Y = 15, S = 1.1 },
			{ K = "Bubble", X = 24, Y = 6, S = 0.6 },
			{ K = "Bubble", X = 24, Y = -6, S = 0.6 },
			{ K = "Bubble", X = 34, Y = 14, S = 0.6 },
			{ K = "Bubble", X = 34, Y = -14, S = 0.6 }
		}
	},
	{
		Name = "Beach Ball",
		Balls = Join(Cues({
			{ 0, 0 },
			{ 0, 8 },
			{ 0, -8 },
			{ -6, 15 }
		}), {
			{ N = 12, X = 30, Y = 0, S = 1.6 }
		}, Golden({
			{ 31, 13 }
		}), Dots({
			{ 0, 14, 3 },
			{ 0, -14, 2 },
			{ 26, -9, 13 }
		}, 1.4)),
		Mods = {
			{ K = "Pocket", X = 40, Y = 0, S = 2 },
			{ K = "Pocket", X = 24, Y = -17, S = 2 },
			{ K = "Pocket", X = 38, Y = 17, S = 1.6 }
		}
	},
	{
		Name = "Sandcastle",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 },
			{ -38, 14 }
		}), Wall(10, -11, 10, 11, 7, 1.3, { 3, 4, 5 }, 13), Ring(10, 15.5, 4.5, 9, 1, 180, 90, 13), Ring(10, -15.5, 4.5, 9, 1, 180, 90, 13), Ring(28, 0, 7, 12, 1.2, 180, 70, 13)),
		Mods = {
			{
				K = "Mud",
				X = 0,
				Y = 0,
				S = 1.1,
				P = 15
			},
			{ K = "Bubble", X = 10, Y = 15.5, S = 0.5 },
			{ K = "Bubble", X = 10, Y = -15.5, S = 0.5 },
			{ K = "Bubble", X = 28, Y = 0, S = 0.6 },
			{ K = "Bubble", X = 40, Y = 15, S = 0.6 }
		}
	},
	{
		Name = "Surf's Up",
		Balls = Join(Cues({
			{ -38, -14 },
			{ -38, -6 },
			{ -38, 2 }
		}), Arc(8, -8, 14, 10, 160, 9, 1.1, 2), Patrol(0, 19.5, 30, 19.5, 18, 1.2)),
		Mods = {
			{
				K = "Fan",
				X = -14,
				Y = -12,
				S = 1,
				R = 0,
				P = 120
			},
			{
				K = "Fan",
				X = 14,
				Y = -14,
				S = 1,
				R = 20,
				P = 120
			},
			{ K = "Bullseye", X = 34, Y = 8, S = 0.45 },
			{
				K = "Mud",
				X = 34,
				Y = 8,
				S = 1.5,
				P = 25
			}
		}
	},
	{
		Name = "Volcano",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Ring(16, 0, 9, 14, 1.3, 180, 50, 13)),
		Mods = {
			{ K = "Lava", X = 16, Y = 0, S = 1.1 },
			{ K = "Trampoline", X = 2, Y = 0, S = 1.3 },
			{ K = "Bubble", X = 16, Y = 0, S = 0.6 },
			{ K = "Bubble", X = 16, Y = 14, S = 0.6 },
			{ K = "Bubble", X = 16, Y = -14, S = 0.6 },
			{ K = "Bubble", X = 30, Y = 0, S = 0.6 }
		}
	},
	{
		Name = "Coral Reef",
		Balls = Join(Cues({
			{ -38, -8 },
			{ -38, 0 },
			{ -38, 8 }
		}), Dots({
			{ 0, 10, 3 },
			{ 2.4, 11, 13 },
			{ 1, 12.8, 1 },
			{ -2, 11.6, 11 },
			{ 14, -8, 6 },
			{ 16.4, -9, 14 },
			{ 15, -6, 2 },
			{ 28, 10, 13 },
			{ 30.4, 9, 3 },
			{ 29, 12.2, 10 }
		}, 1), Golden({
			{ 8, 4 },
			{ 22, -2 },
			{ 30, -12 }
		})),
		Mods = {
			{
				K = "Fan",
				X = -12,
				Y = 0,
				S = 0.8,
				R = 0,
				P = 80
			},
			{ K = "Pocket", X = 40, Y = 0, S = 1.5 },
			{ K = "Pocket", X = 36, Y = 18, S = 1.4 },
			{ K = "Pocket", X = 36, Y = -18, S = 1.4 },
			{ K = "Pocket", X = 20, Y = 18, S = 1.2 }
		}
	},
	{
		Name = "Tidal Pool",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Arc(18, 0, 12, 35, 145, 6, 1.4, 7), Arc(18, 0, 12, 215, 325, 6, 1.4, 7)),
		Mods = {
			{ K = "Bullseye", X = 18, Y = 0, S = 0.5 },
			{
				K = "BlackHole",
				X = 18,
				Y = 0,
				S = 0.6,
				P = 80
			},
			{
				K = "Fan",
				X = 0,
				Y = 16,
				S = 0.8,
				R = 270,
				P = 80
			}
		}
	},
	{
		Name = "Fireworks",
		Balls = Join(Cues({
			{ -38, -6 },
			{ -38, 0 },
			{ -38, 6 }
		}), Hex(14, 0, 1, { 3, 1, 2, 6, 13, 11, 7 })),
		Mods = {
			{
				K = "Boost",
				X = -16,
				Y = 0,
				S = 0.9,
				P = 1.6
			},
			{ K = "Bubble", X = 28, Y = 0, S = 0.55 },
			{ K = "Bubble", X = 21, Y = 12.1, S = 0.55 },
			{ K = "Bubble", X = 7, Y = 12.1, S = 0.55 },
			{ K = "Bubble", X = 7, Y = -12.1, S = 0.55 },
			{ K = "Bubble", X = 21, Y = -12.1, S = 0.55 },
			{ K = "Bubble", X = 0, Y = 0, S = 0.55 }
		}
	},
	{
		Name = "Treasure Island",
		Balls = Join(Cues({
			{ -38, 0 },
			{ -38, -6 },
			{ -38, 6 },
			{ -38, 12 }
		}), Ring(18, 0, 13, 22, 1.3, 180, 70, 7), Rack(14, 0, 2, { 12, 12, 12 }), Golden({
			{ 34, 16 }
		}), Patrol(0, -18, 0, 18, 24, 1.4)),
		Mods = {
			{ K = "Pocket", X = 24, Y = 0, S = 1.9 },
			{ K = "Pocket", X = 40, Y = 17, S = 1.6 },
			{ K = "Trampoline", X = 4, Y = 14, S = 1.1 }
		}
	},
	{
		Name = "Rollercoaster",
		TL = 1.8,
		Balls = Join(Cues({
			{ -70, 0 },
			{ -70, -8 },
			{ -70, 8 },
			{ -70, 16 }
		}), Wall(-36, -20, -36, -4, 5, 1.3, nil, 3), Wall(-4, 4, -4, 20, 5, 1.3, nil, 2), Arc(30, 0, 8, 35, 145, 6, 1.2, 13), Arc(30, 0, 8, 215, 325, 6, 1.2, 13)),
		Mods = {
			{ K = "Trampoline", X = -46, Y = -6, S = 1.2 },
			{ K = "Trampoline", X = -14, Y = 6, S = 1.2 },
			{
				K = "Boost",
				X = -54,
				Y = 12,
				S = 1,
				P = 1.5
			},
			{
				K = "Boost",
				X = 14,
				Y = -12,
				S = 1,
				P = 1.5
			},
			{ K = "Bullseye", X = 62, Y = 0, S = 0.65 },
			{
				K = "Mud",
				X = 62,
				Y = 0,
				S = 2.2,
				P = 38
			}
		}
	},
	{
		Name = "Grand Carnival",
		Balls = Join(Cues({
			{ -38, -12 },
			{ -38, -4 },
			{ -38, 4 },
			{ -38, 12 }
		}), Spinner(10, 0, 3, 1, 50, 1), Arc(10, 0, 14, 35, 145, 6, 1.1, 3), Arc(10, 0, 14, 215, 325, 6, 1.1, 2), Patrol(30, -18, 30, 18, 22, 1.4)),
		Mods = {
			{ K = "Trampoline", X = -14, Y = -12, S = 1.1 },
			{
				K = "Boost",
				X = -20,
				Y = 4,
				S = 1,
				P = 1.4
			},
			{
				K = "Fan",
				X = 38,
				Y = 0,
				S = 0.8,
				R = 90,
				P = 80
			},
			{ K = "Bubble", X = 10, Y = 10.5, S = 0.5 },
			{ K = "Bubble", X = 10, Y = -10.5, S = 0.5 },
			{ K = "Bubble", X = 24, Y = 14, S = 0.6 },
			{ K = "Bubble", X = 24, Y = -14, S = 0.6 },
			{ K = "Bubble", X = 38, Y = 14, S = 0.6 },
			{ K = "Bubble", X = -8, Y = 16, S = 0.6 }
		}
	}
}

function PoolLevelCatalog.SceneFor(p: number)
	local v2 = v[p]

	if not v2 then
		return nil
	end

	local sanitise = PoolTrickshotTypes.Sanitise(v2, v2.Name)

	if not sanitise then
		warn(string.format("[Levels] level %d has an invalid layout and cannot be loaded", p))
	end

	return sanitise
end

function PoolLevelCatalog.IsAuthored(p: number): boolean
	return v[p] ~= nil
end

PoolLevelCatalog.Count = 500

PoolLevelCatalog.Themes = { "Winter", "Summer", "Sakura", "Pirate", "Desert" }

PoolLevelCatalog.ThemeBlock = 20

local v2 = { "Bullseye", "Pocket", "Bubble" }

function PoolLevelCatalog.ThemeFor(p: number)
	local themes = PoolLevelCatalog.Themes
	return themes[math.floor((p - 1) / PoolLevelCatalog.ThemeBlock) % #themes + 1]
end

function PoolLevelCatalog.GoalFor(p: number)
	if p <= 10 then
		return "Bullseye"
	end

	return v2[(p - 1) % #v2 + 1]
end

function PoolLevelCatalog.BallsFor(p: number)
	return (math.clamp(math.floor((p - 1) / 60) + 3, 3, 6))
end

function PoolLevelCatalog.Get(p: number)
	if p < 1 or PoolLevelCatalog.Count < p or p % 1 ~= 0 then
		return nil
	end

	return {
		Index = p,
		Theme = PoolLevelCatalog.ThemeFor(p),
		Goal = PoolLevelCatalog.GoalFor(p),
		Balls = PoolLevelCatalog.BallsFor(p),
		Scene = PoolLevelCatalog.SceneFor(p)
	}
end

function PoolLevelCatalog.All()
	local result = table.create(PoolLevelCatalog.Count)

	for i = 1, PoolLevelCatalog.Count do
		result[i] = PoolLevelCatalog.Get(i)
	end

	return result
end

return PoolLevelCatalog