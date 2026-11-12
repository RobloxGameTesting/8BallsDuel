local Material = Enum.Material

local function newPart(p, name: string, size: Vector3, cframe: CFrame, color: Color3, p2, value: number?)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false

	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = p2 or Material.SmoothPlastic
	part.Color = color
	part.Transparency = value or 0
	part.Size = size
	part.CFrame = cframe
	part.Parent = p.Group

	return part
end

local function at(p, p2: number, p3: number, p4: number) -- 11 equivalent calls inferred from this helper
	return p.Origin * CFrame.new(p2, p4, -p3)
end

local function disc(p, name: string, p2: number, p3: number, p4: number, p5: number, p6: number, color: Color3, p7, p8: number?)
	local v = newPart(
		p,
		name,
		Vector3.new(p6, p5, p5),
		at(p, p2, p3, p4 + p6 / 2) * CFrame.Angles(0, 0, 1.5707963267948966), -- inferred equivalent call
		color,
		p7,
		p8
	)

	v.Shape = Enum.PartType.Cylinder

	return v
end

local function barFrame(p, p2: number, p3: number, p4: number, p5: number, p6: number) -- 2 equivalent calls inferred from this helper
	return at(p, p2, p3, p4 + p5 / 2) * CFrame.Angles(0, math.rad(p6), 0) -- inferred equivalent call
end

local function bar(p, name: string, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, color: Color3, p9, p10: number?) -- 1 equivalent call inferred from this helper
	return newPart(p, name, Vector3.new(p5, p7, p6), barFrame(p, p2, p3, p4, p7, p8), color, p9, p10) -- inferred equivalent call
end

local function ellipse(p, name: string, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, color: Color3, p9, p10: number?)
	local parent = bar(p, name, p2, p3, p4, p5, p6, p7, p8, color, p9, p10) -- inferred equivalent call
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = parent

	return parent
end

local function placeChevron(p, data, p2: number, p3: number, p4: number, p5: number)
	for k, arm in data.Arms do
		local v = math.rad(p5 + 180 + (k == 1 and 45 or -45))
		local v2 = data.Length / 2 - data.Width / 2
		arm.CFrame = barFrame(p, p2 + math.cos(v) * v2, p3 + math.sin(v) * v2, p4, data.Thickness, math.deg(v)) -- inferred equivalent call
	end
end

local function chevron(p, name: string, p2: number, p3: number, p4: number, p5: number, length: number, width: number, thickness: number, color: Color3, neon, p6: number?)
	local v = { Arms = {}, Length = length, Width = width, Thickness = thickness }

	for _ = 1, 2 do
		local arms = v.Arms
		local vector3 = Vector3.new(length, thickness, width)
		table.insert(
			arms,
			newPart(p, name, vector3, at(p, 0, 0, p4 + thickness / 2) * CFrame.Angles(0, 0, 0), color, neon, p6) -- inferred equivalent call
		)
	end

	placeChevron(p, v, p2, p3, p4, p5)

	return v
end

local function setChevronTransparency(p, transparency: number) -- 3 equivalent calls inferred from this helper
	for _, arm in p.Arms do
		arm.Transparency = transparency
	end
end

local function seededFor(p)
	local v = (typeof(p) ~= "table" or typeof(p.X) ~= "number") and 0 or p.X
	local v2 = (typeof(p) ~= "table" or typeof(p.Y) ~= "number") and 0 or p.Y

	return Random.new(math.floor((math.abs(v * 7919 + v2 * 104729 + 17))) % 2147483647)
end

local v = {
	Shadow = Color3.fromRGB(16, 42, 98),
	Pad = Color3.fromRGB(40, 108, 220),
	PadLight = Color3.fromRGB(96, 160, 248),
	Pleat = Color3.fromRGB(20, 60, 146),
	Mat = Color3.fromRGB(24, 24, 28),
	Sheen = Color3.fromRGB(36, 36, 44),
	SheenHot = Color3.fromRGB(48, 48, 58),
	Hook = Color3.fromRGB(206, 212, 220)
}

local function buildTrampoline(p, p2): nil
	local radius = p.Radius
	local v2 = v

	p2.Color = v2.Shadow

	disc(p, "Padding", 0, 0, 0, radius * 2, 0.1, v2.Pad)

	disc(p, "PaddingLight", 0, 0, 0.1, radius * 1.86, 0.008, v2.PadLight)
	disc(p, "PaddingTop", 0, 0, 0.108, radius * 1.7, 0.008, v2.Pad)

	for i = 0, 17 do
		local v3 = i * 20 + 10
		local v4 = math.rad(v3)

		local v5 = math.cos(v4) * radius * 0.85
		local v6 = math.sin(v4) * radius * 0.85
		local v7 = radius * 0.22
		local v8 = radius * 0.035
		local pleat = v2.Pleat
		newPart(
			p,
			"Pleat",
			Vector3.new(v7, 0.006, v8),
			at(p, v5, v6, 0.11900000000000001) * CFrame.Angles(0, math.rad(v3), 0), -- inferred equivalent call
			pleat,
			nil,
			0.4
		)
	end

	disc(p, "Mat", 0, 0, 0.122, radius * 1.36, 0.01, v2.Mat, Material.Fabric)

	disc(p, "Sheen", -radius * 0.06, radius * 0.06, 0.132, radius * 0.98, 0.004, v2.Sheen, Material.Fabric)
	disc(p, "SheenHot", -radius * 0.14, radius * 0.14, 0.136, radius * 0.46, 0.004, v2.SheenHot, Material.Fabric)

	for i = 0, 15 do
		local v3 = i * 22.5
		local v4 = math.rad(v3)

		local v5 = math.cos(v4) * radius * 0.69
		local v6 = math.sin(v4) * radius * 0.69
		local v7 = radius * 0.08
		local v8 = radius * 0.03
		local hook = v2.Hook
		local metal = Material.Metal
		newPart(
			p,
			"Hook",
			Vector3.new(v7, 0.008, v8),
			at(p, v5, v6, 0.134) * CFrame.Angles(0, math.rad(v3), 0), -- inferred equivalent call
			hook,
			metal,
			nil
		)
	end

	return nil
end

local v2 = {
	Rim = Color3.fromRGB(64, 68, 78),
	Plate = Color3.fromRGB(178, 182, 190),
	Recess = Color3.fromRGB(116, 120, 130),
	Bolt = Color3.fromRGB(222, 226, 232),
	Glow = Color3.fromRGB(255, 196, 36),
	Core = Color3.fromRGB(255, 214, 80)
}

local function buildBoost(p, p2)
	local radius = p.Radius
	local v3 = v2

	p2.Color = v3.Rim
	p2.Material = Material.Metal
	p2.Transparency = 0

	disc(p, "Plate", 0, 0, 0, radius * 1.8, 0.05, v3.Plate, Material.Metal)
	disc(p, "Recess", 0, 0, 0.05, radius * 1.5, 0.006, v3.Recess, Material.DiamondPlate)

	for i = 0, 5 do
		local v4 = math.rad(i * 60 + 30)

		disc(
			p,
			"Bolt",
			math.cos(v4) * radius * 0.82,
			math.sin(v4) * radius * 0.82,
			0.05,
			radius * 0.11,
			0.012,
			v3.Bolt,
			Material.Metal
		)
	end

	local v4 = {}
	local v5 = {}

	for i = 0, 3 do
		local v6 = i * 90
		local v7 = math.rad(v6)

		table.insert(
			v4,
			chevron(
				p,
				"Chevron",
				math.cos(v7) * radius * 0.44,
				math.sin(v7) * radius * 0.44,
				0.056,
				v6,
				radius * 0.24,
				radius * 0.09,
				0.01,
				v3.Glow,
				Material.Neon
			)
		)
		table.insert(
			v5,
			chevron(
				p,
				"Chevron",
				math.cos(v7) * radius * 0.66,
				math.sin(v7) * radius * 0.66,
				0.056,
				v6,
				radius * 0.24,
				radius * 0.09,
				0.01,
				v3.Glow,
				Material.Neon
			)
		)
	end

	disc(p, "Hub", 0, 0, 0.056, radius * 0.34, 0.01, v3.Rim, Material.Metal)
	local v6 = disc(p, "Core", 0, 0, 0.066, radius * 0.22, 0.01, v3.Core, Material.Neon)

	return function(p3: number)
		local function glow(p4: number) -- 3 equivalent calls inferred from this helper
			return (math.sin(p3 * 6 - p4) * 0.5 + 0.5) * 0.5 + 0.05
		end

		v6.Transparency = glow(0) -- inferred equivalent call

		for _, v7 in v4 do
			setChevronTransparency(v7, glow(1.2)) -- inferred equivalent call
		end

		for _, v7 in v5 do
			setChevronTransparency(v7, glow(2.4)) -- inferred equivalent call
		end
	end
end

local v3 = {
	Dark = Color3.fromRGB(70, 42, 22),
	Wet = Color3.fromRGB(122, 78, 42),
	Light = Color3.fromRGB(148, 102, 60),
	Glint = Color3.fromRGB(196, 158, 112)
}

local function buildMud(p, p2, p3): nil
	local radius = p.Radius
	local v4 = v3
	local v5 = seededFor(p3)

	p2.Transparency = 1

	disc(p, "Puddle", 0, 0, 0, radius * 1.6, 0.04, v4.Dark, Material.Mud)

	for i = 1, 8 do
		local v6 = i / 8 * 6.283185307179586 + v5:NextNumber(-0.25, 0.25)
		local number = v5:NextNumber(0.3, 0.42)
		local v7 = 1 - number

		disc(
			p,
			"Lobe",
			math.cos(v6) * radius * v7,
			math.sin(v6) * radius * v7,
			0,
			radius * number * 2,
			0.04,
			v4.Dark,
			Material.Mud
		)
	end

	local v6 = v5:NextNumber(-0.12, 0.12) * radius
	local v7 = v5:NextNumber(-0.12, 0.12) * radius

	disc(p, "Wet", v6, v7, 0.04, radius * 0.7, 0.006, v4.Wet, Material.Mud)

	for i = 1, 5 do
		local v8 = i / 5 * 6.283185307179586 + v5:NextNumber(-0.3, 0.3)
		local number = v5:NextNumber(0.14, 0.22)
		local v9 = 0.36 - number * 0.4

		disc(
			p,
			"Wet",
			v6 + math.cos(v8) * radius * v9,
			v7 + math.sin(v8) * radius * v9,
			0.04,
			radius * number * 2,
			0.006,
			v4.Wet,
			Material.Mud
		)
	end

	disc(p, "WetLight", v6 - radius * 0.06, v7 + radius * 0.05, 0.046, radius * 0.32, 0.004, v4.Light, Material.Mud)

	for _ = 1, 4 do
		local number = v5:NextNumber(0, 6.283185307179586)
		local number2 = v5:NextNumber(1.02, 1.14)

		disc(
			p,
			"Splash",
			math.cos(number) * radius * number2,
			math.sin(number) * radius * number2,
			0,
			radius * v5:NextNumber(0.08, 0.14),
			0.04,
			v4.Dark,
			Material.Mud
		)
	end

	for _ = 1, 4 do
		local number = v5:NextNumber(0, 6.283185307179586)
		local number2 = v5:NextNumber(0.25, 0.7)

		disc(
			p,
			"Glint",
			math.cos(number) * radius * number2,
			math.sin(number) * radius * number2,
			0.05,
			radius * v5:NextNumber(0.05, 0.09),
			0.004,
			v4.Glint,
			nil,
			0.25
		)
	end

	return nil
end

local v4 = {
	Crust = Color3.fromRGB(44, 20, 14),
	Lava = Color3.fromRGB(255, 92, 28),
	Haze = Color3.fromRGB(255, 64, 16),
	Glow = Color3.fromRGB(255, 128, 40),
	Heart = Color3.fromRGB(255, 206, 96),
	Bubble = Color3.fromRGB(255, 230, 150)
}

local function buildLava(p, p2, p3)
	local radius = p.Radius
	local v5 = v4
	local v6 = seededFor(p3)

	p2.Color = v5.Crust
	p2.Material = Material.Basalt
	p2.Transparency = 0

	for i = 1, 7 do
		local v7 = i / 7 * 6.283185307179586 + v6:NextNumber(-0.2, 0.2)
		local number = v6:NextNumber(0.26, 0.34)

		disc(
			p,
			"Crust",
			math.cos(v7) * radius * (1.02 - number),
			math.sin(v7) * radius * (1.02 - number),
			0,
			radius * number * 2,
			0.03,
			v5.Crust,
			Material.Basalt
		)
	end

	disc(p, "Lava", 0, 0, 0.03, radius * 1.66, 0.01, v5.Lava, Material.CrackedLava)

	disc(p, "Haze", 0, 0, 0.04, radius * 1.66, 0.004, v5.Haze, Material.Neon, 0.82)
	disc(p, "Glow", 0, 0, 0.044, radius * 1, 0.004, v5.Glow, Material.Neon, 0.76)
	disc(p, "Glow", -radius * 0.03, radius * 0.03, 0.048, radius * 0.62, 0.004, v5.Glow, Material.Neon, 0.68)
	disc(p, "Heart", -radius * 0.05, radius * 0.05, 0.052, radius * 0.3, 0.004, v5.Heart, Material.Neon, 0.55)

	local v7 = {}

	for i = 1, 4 do
		local number = v6:NextNumber(0, 6.283185307179586)
		local v8 = v6:NextNumber(0.1, 0.58) * radius
		local size = v6:NextNumber(0.12, 0.18) * radius
		local v9 = math.cos(number) * v8
		local v10 = math.sin(number) * v8

		table.insert(v7, {
			Part = disc(p, "Bubble", v9, v10, 0.058, size, 0.008, v5.Bubble, Material.Neon, 1),
			X = v9,
			Y = v10,
			Size = size,
			Offset = i * 0.37 + v6:NextNumber(0, 1),
			Period = v6:NextNumber(1.4, 2.2)
		})
	end

	return function(p4: number)
		for _, v8 in v7 do
			local v9 = (p4 + v8.Offset) / v8.Period % 1
			local v10 = math.min(v9 / 0.8, 1)
			local v11 = v8.Size * (v10 * 0.7 + 0.3)
			local part = v8.Part

			part.Size = Vector3.new(part.Size.X, v11, v11)
			part.Transparency = v9 > 0.8 and 1 or v10 * 0.5 + 0.15
		end
	end
end

local v5 = {
	Field = Color3.fromRGB(122, 196, 224),
	Edge = Color3.fromRGB(196, 238, 252),
	Rim = Color3.fromRGB(28, 32, 40),
	Housing = Color3.fromRGB(62, 68, 80),
	Grille = Color3.fromRGB(22, 24, 30),
	Blade = Color3.fromRGB(214, 222, 232),
	Hub = Color3.fromRGB(240, 244, 248),
	Wind = Color3.fromRGB(226, 248, 255)
}

local v6 = { -0.42, 0, 0.42 }

local function buildFan(p, p2)
	local radius = p.Radius
	local v7 = v5

	p2.Color = v7.Field
	p2.Transparency = 0.84

	for i = 0, 29 do
		local v8 = i / 30 * 6.283185307179586
		local v9 = math.deg(v8) + 90

		local v10 = math.cos(v8) * radius * 0.97
		local v11 = math.sin(v8) * radius * 0.97
		local v12 = 6.283185307179586 * radius / 30 * 0.5
		local v13 = radius * 0.03
		local edge = v7.Edge
		newPart(
			p,
			"Edge",
			Vector3.new(v12, 0.01, v13),
			at(p, v10, v11, 0.005) * CFrame.Angles(0, math.rad(v9), 0), -- inferred equivalent call
			edge,
			nil,
			0.3
		)
	end

	local v8 = -radius * 0.66

	disc(p, "Rim", v8, 0, 0, radius * 0.66, 0.06, v7.Rim, Material.Metal)
	disc(p, "Housing", v8, 0, 0.06, radius * 0.6, 0.01, v7.Housing, Material.Metal)
	disc(p, "Grille", v8, 0, 0.07, radius * 0.5, 0.004, v7.Grille)

	disc(p, "Sweep", v8, 0, 0.074, radius * 0.48, 0.002, v7.Blade, nil, 0.82)

	local v9 = {}

	for _ = 1, 3 do
		local v10 = radius * 0.24
		local v11 = radius * 0.12
		local blade = v7.Blade
		local metal = Material.Metal
		local parent = newPart(
			p,
			"Blade",
			Vector3.new(v10, 0.01, v11),
			p.Origin * CFrame.new(v8, 0.081, -0) * CFrame.Angles(0, 0, 0),
			blade,
			metal,
			nil
		)

		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Parent = parent

		table.insert(v9, parent)
	end

	disc(p, "Hub", v8, 0, 0.086, radius * 0.11, 0.012, v7.Hub, Material.Metal)
	disc(p, "Cap", v8, 0, 0.098, radius * 0.05, 0.006, v7.Rim, Material.Metal)

	local v10 = {}

	for _, row in v6 do
		for i = 0, 3 do
			table.insert(v10, {
				Chevron = chevron(
					p,
					"Wind",
					0,
					0,
					0.02,
					0,
					radius * 0.15,
					radius * 0.04,
					0.008,
					v7.Wind,
					Material.Neon,
					1
				),
				Row = row,
				Start = i * 0.34 + -0.36
			})
		end
	end

	return function(p3: number)
		local v11 = p3 * 9

		for k, v12 in v9 do
			local v13 = v11 + (k - 1) * 2.0943951023931953
			local v14 = radius * 0.13

			local v15 = v8 + math.cos(v13) * v14
			local v16 = math.sin(v13) * v14
			local v17 = math.deg(v13) + 22
			v12.CFrame = at(p, v15, v16, 0.081) * CFrame.Angles(0, math.rad(v17), 0) -- inferred equivalent call
		end

		local v12 = p3 * 0.5 % 1.36

		for _, v13 in v10 do
			local v14 = (v13.Start - -0.36 + v12) % 1.36 + -0.36
			local v15 = v14 * radius
			local v16 = v13.Row * radius

			placeChevron(p, v13.Chevron, v15, v16, 0.02, 0)

			local v17 = (v14 - -0.36) / 1.3199999999999998
			local v18 = math.clamp(math.min(v17 / 0.2, (1 - v17) / 0.25), 0, 1)
			local v19 = math.sqrt(v15 * v15 + v16 * v16) < radius * 0.9

			setChevronTransparency(v13.Chevron, not v19 and 1 or 1 - v18 * 0.75) -- inferred equivalent call
		end
	end
end

local v7 = {
	Field = Color3.fromRGB(88, 52, 168),
	Outer = Color3.fromRGB(72, 40, 144),
	Inner = Color3.fromRGB(210, 156, 255),
	Ring = Color3.fromRGB(176, 104, 255),
	RingHot = Color3.fromRGB(238, 206, 255),
	Horizon = Color3.fromRGB(0, 0, 0)
}

local function buildBlackHole(p, p2)
	local radius = p.Radius
	local v8 = v7

	p2.Color = v8.Field
	p2.Transparency = 0.84

	local v9 = {}

	for i = 0, 2 do
		for j = 0, 25 do
			local v10 = j / 25
			local v11 = radius * (0.16 - v10 * 0.09)
			local lerped = v8.Outer:Lerp(v8.Inner, v10)
			local v12

			if v10 > 0.55 then
				v12 = Material.Neon
			else
				v12 = Material.SmoothPlastic
			end

			table.insert(v9, {
				Part = disc(p, "Dust", 0, 0, v10 * 0.01 + 0.01, v11, 0.006, lerped, v12, 0.7 - v10 * 0.55),
				Arm = i,
				F = v10
			})
		end
	end

	disc(p, "Ring", 0, 0, 0.03, radius * 0.64, 0.008, v8.Ring, Material.Neon, 0.2)
	disc(p, "RingHot", 0, 0, 0.038, radius * 0.52, 0.008, v8.RingHot, Material.Neon, 0.1)
	disc(p, "Horizon", 0, 0, 0.046, radius * 0.42, 0.01, v8.Horizon)

	local function place(p3: number)
		local v10 = p3 * 0.8

		for _, v11 in v9 do
			local v12 = v11.Arm * 2.0943951023931953 + v11.F * 2.7 + v10
			local v13 = radius * (0.95 - v11.F * 0.64)
			local part = v11.Part

			part.CFrame = at(p, math.cos(v12) * v13, math.sin(v12) * v13, v11.F * 0.01 + 0.01 + part.Size.X / 2) * CFrame.Angles(0, 0, 1.5707963267948966) -- inferred equivalent call
		end
	end

	place(0)

	return place
end

local v8 = {
	Rim = Color3.fromRGB(176, 104, 14),
	Edge = Color3.fromRGB(232, 146, 20),
	Body = Color3.fromRGB(255, 184, 36),
	Lit = Color3.fromRGB(255, 214, 92),
	Shine = Color3.fromRGB(255, 255, 255)
}

local function dome(p, name: string, p2: number, p3: number, p4: number, p5: number, p6: number, color: Color3, p7: number?, value: number?)
	local parent = newPart(
		p,
		name,
		Vector3.new(p4, p6, p5),
		at(p, p2, p3, 0) * CFrame.Angles(0, (math.rad)(value or 0), 0), -- inferred equivalent call
		color,
		nil,
		p7
	)

	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = parent

	return parent
end

local function buildBubble(p, p2)
	local radius = p.Radius
	local v9 = v8

	p2.Color = v9.Rim
	p2.Transparency = 0

	local dome_2 = dome(p, "Edge", 0, 0, radius * 1.94, radius * 1.94, 0.46, v9.Edge)
	dome_2.Reflectance = 0.1

	local dome_3 = dome(p, "Body", -radius * 0.05, radius * 0.05, radius * 1.66, radius * 1.66, 0.5, v9.Body)
	dome_3.Reflectance = 0.12

	dome(p, "Lit", -radius * 0.14, radius * 0.14, radius * 1, radius * 1, 0.54, v9.Lit)
	dome(p, "Shine", -radius * 0.4, radius * 0.4, radius * 0.52, radius * 0.24, 0.6, v9.Shine, 0.1, 45)
	dome(p, "Glint", radius * 0.36, -radius * 0.42, radius * 0.22, radius * 0.12, 0.58, v9.Shine, 0.45, 45)

	local v10 = radius * 0.46
	local v11 = radius * 0.4

	local v12 = radius * 0.36
	local v13 = radius * 0.05
	local shine = v9.Shine
	local neon = Material.Neon
	local v14 = newPart(
		p,
		"Twinkle",
		Vector3.new(v12, 0.006, v13),
		at(p, v10, v11, 0.313) * CFrame.Angles(0, 0, 0), -- inferred equivalent call
		shine,
		neon,
		1
	)

	local v15 = radius * 0.36
	local v16 = radius * 0.05
	local shine2 = v9.Shine
	local neon2 = Material.Neon
	local v17 = {
		v14,
		newPart(
			p,
			"Twinkle",
			Vector3.new(v15, 0.006, v16),
			at(p, v10, v11, 0.313) * CFrame.Angles(0, 1.5707963267948966, 0), -- inferred equivalent call
			shine2,
			neon2,
			1
		)
	}

	return function(p3: number)
		local v18 = p3 / 2.6 % 1
		local v19 = not (v18 < 0.18) and 0 or math.sin(v18 / 0.18 * 3.141592653589793)

		for _, v20 in v17 do
			v20.Transparency = 1 - v19 * 0.9
			v20.Size = Vector3.new(radius * (v19 * 0.3 + 0.15), v20.Size.Y, v20.Size.Z)
		end
	end
end

local v9 = {
	Casing = Color3.fromRGB(176, 180, 190),
	Lip = Color3.fromRGB(38, 38, 44),
	Throat = Color3.fromRGB(14, 14, 16),
	Core = Color3.fromRGB(0, 0, 0)
}

local function buildPocket(p, p2): nil
	local radius = p.Radius
	local v10 = v9

	p2.Transparency = 0

	local disc_2 = disc(p, "Casing", 0, 0, 0, radius * 2.44, 0.04, v10.Casing, Material.Metal)
	disc_2.Reflectance = 0.2

	disc(p, "Lip", 0, 0, 0.04, radius * 2, 0.006, v10.Lip)
	disc(p, "Throat", 0, 0, 0.046, radius * 1.7, 0.006, v10.Throat)
	disc(p, "Core", 0, 0, 0.052, radius * 1.1, 0.006, v10.Core)

	return nil
end

local v10 = {
	Trampoline = buildTrampoline,
	Boost = buildBoost,
	Mud = buildMud,
	Lava = buildLava,
	Fan = buildFan,
	BlackHole = buildBlackHole,
	Bubble = buildBubble,
	Pocket = buildPocket
}
local PoolModifierArt = {}

function PoolModifierArt.Build(group, p: string, p2, radius: number, p3)
	local v11 = v10[p]

	if not v11 then
		return nil
	end

	local v12 = p2.Position + Vector3.new(0, p2.Size.X / 2, 0)
	local v13 = (typeof(p3) ~= "table" or typeof(p3.R) ~= "number") and 0 or p3.R

	return v11({
		Group = group,
		Origin = CFrame.new(v12) * CFrame.Angles(0, math.rad(v13), 0),
		Radius = radius
	}, p2, p3)
end

function PoolModifierArt.Has(p: string): boolean
	return v10[p] ~= nil
end

return PoolModifierArt