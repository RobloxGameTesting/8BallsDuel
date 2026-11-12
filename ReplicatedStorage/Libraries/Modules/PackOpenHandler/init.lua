local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
require(ReplicatedStorage.Libraries.Modules.Button)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local ClientSounds = require(ReplicatedStorage.Libraries.Modules.ClientSounds)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local CameraShaker = require(ReplicatedStorage.Libraries.Classes.CameraShaker)
local RunService = game:GetService("RunService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Colours = require(ReplicatedStorage.Libraries.Modules.Colours)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.Classes.Animations)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Modules.Gamepasses)
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Libraries.Helpers.CameraHelper)
local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local ClientEvents = require(ReplicatedStorage.Libraries.Modules.ClientEvents)
require(ReplicatedStorage.Libraries.Helpers.ViewportHelper)
local ContextActionService = game:GetService("ContextActionService")
local CFrameHelper = require(ReplicatedStorage.Libraries.Helpers.CFrameHelper)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local PackOpenConfiguration = require(script.PackOpenConfiguration)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local packOpenUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PackOpenUI")
local userId = tostring(LocalPlayer.UserId)
local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data
local Packs = ReplicatedStorage.Assets.Packs
LocalPlayer:GetMouse()
local v = { "PackOpen" }
local v2 = Maid.new()
local OnPackOpenFinished = ClientEvents.OnPackOpenFinished
local CurrentCamera = workspace.CurrentCamera
local displayMaid = Maid.new()

local Display = script.Display
local v3 = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(_) end)
local owned = packOpenUI:FindFirstChild("Owned")
local subheader = packOpenUI:FindFirstChild("Subheader")
local itemName = packOpenUI:FindFirstChild("ItemName")
local uiGradient = itemName:FindFirstChild("UIGradient")
local rarity = packOpenUI:FindFirstChild("Rarity")

local v4 = 2
local v5 = 0
local numberTween = NumberHelper:NumberTween(v4)
local numberTween2 = NumberHelper:NumberTween(v5)
local v6 = CFrame.Angles(0, 0, 0)
local v7 = nil

local cameraMinZoomDistance = nil
local v8 = {}

local PackOpenHandler = {}

function PackOpenHandler.Init()
	numberTween.Updated:Connect(function(p)
		v4 = p
	end)

	numberTween2.Updated:Connect(function(p)
		v5 = p
	end)

	Menu.Opened:Connect(function(p, _, ...)
		if p == "PackOpen" then
			Mouselock:Off()
			displayMaid:Destroy()
			cameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance
			LocalPlayer.CameraMinZoomDistance = 5

			Sounds.Play(ClientSounds.MenuOpen, nil, false)

			local v9 = { ... }
			local v10 = v9[1]
			local v11 = v9[2]
			local v12 = v9[3]
			v7 = v9[4]

			for i = 1, v11 do
				PackOpenHandler.Open(i, v11, v10, v12)
			end
		end
	end)

	Menu.Closed:Connect(function(p)
		if p == "PackOpen" then
			Mouselock:Enable()
			displayMaid:Destroy()
			v2:Destroy()

			if cameraMinZoomDistance then
				LocalPlayer.CameraMinZoomDistance = cameraMinZoomDistance
			end
		end
	end)

	RemoteSignals.OnClientEvent("Packs", function(p, ...)
		if not table.find(v, p) then
			return
		end

		local v9 = { ... }
		local v10 = v9[1]
		local v11 = v9[2]
		local v12 = v9[3]

		Menu.Open("PackOpen", nil, v10, v11, v12, Menu.GetMenu())
	end)
end

function PackOpenHandler.Open(p: number, p2: number, childName: string, p3)
	local child = Packs:FindFirstChild(childName)
	local module = require(child)
	local packType = module.packType
	local v9 = data.configuration.misc.instaOpen == "On"
	local v10 = p3[p]
	local itemData = InventoryHelpers.GetItemData(packType, v10.item)
	local _chance = v10.chance
	local rarity2 = itemData.rarity({}, itemData)
	local colour = Colours[rarity2]

	displayMaid:Destroy()

	local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
	depthOfFieldEffect.FarIntensity = 1
	depthOfFieldEffect.FocusDistance = 0
	depthOfFieldEffect.InFocusRadius = 2.5
	depthOfFieldEffect.NearIntensity = 0.75
	depthOfFieldEffect.Parent = Lighting
	local v11 = Visuals.new({ "PackOpening", "PackOpenPassive" }, Vector3.new(0, 0, 0))
	local v12 = Visuals.new({ "PackOpening", "PackOpenClick" }, Vector3.new(0, 0, 0))
	local v13 = Visuals.new({ "PackOpening", "PackOpenReveal" }, Vector3.new(0, 0, 0))

	PackOpenHandler.AddToViewport(Visuals.GetObject(v11))
	PackOpenHandler.AddToViewport(Visuals.GetObject(v12))
	PackOpenHandler.AddToViewport(Visuals.GetObject(v13))

	Visuals.Recolour(v12, colour.Keypoints[1].Value)
	Visuals.Recolour(v13, colour.Keypoints[1].Value)
	Visuals.Play(v11, "Manual", false)

	local clone = module.instance:Clone()
	local v14 = PackOpenHandler.ApplyOutline(clone)
	ModelHelper:Size(clone, 0, 0.2)
	ModelHelper.CanCollide(clone, false)
	clone.Parent = workspace
	displayMaid.packDisplay = RunService.RenderStepped:Connect(function(dt: number)
		local v15 = v3:Update(dt)
		clone:PivotTo(CurrentCamera.CFrame * v15 * CFrame.new(0, v5, 0) * v6 + CurrentCamera.CFrame.LookVector * v4)

		local cframe = CFrame.new(
			(CurrentCamera.CFrame + CurrentCamera.CFrame.LookVector * 2).Position,
			CurrentCamera.CFrame.Position
		)

		for _, v16 in v8 do
			v16:PivotTo(cframe)
		end
	end)
	function displayMaid.cleanUpPack()
		itemName.Text = ""
		rarity.Text = ""
	end

	v2.depthOfField = depthOfFieldEffect
	v2.pack = clone
	function v2.cleanUp()
		v8 = {}
		Visuals.Destroy(v13)
		Visuals.Destroy(v12)
		Visuals.Destroy(v11)
	end
	v3:Start()
	owned.Text = p2 - (p - 1) .. "x"

	v2.openListener = OnPackOpenFinished.Event:Connect(function()
		if p == p2 then
			Menu.Close("PackOpen")

			if v7 and v7 ~= "PackOpen" then
				Menu.Open(v7)
			end

			v3:Stop()
		end
	end)

	Sounds.Play(Sounds.new({ "PackOpening", "Open" }), nil, true)
	Sounds.Play(Sounds.new({ "PackOpening", "Open2" }), nil, true)

	PackOpenHandler.YVectorTween(0, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out))
	local v15 = v9 and 1 or 3
	local count = 0
	subheader.Visible = true
	subheader.Text = "CLICK " .. v15 - count .. " TIMES TO OPEN"

	local function onTap(_: string, begin, _)
		if begin ~= Enum.UserInputState.Begin then
			return
		end

		count += 1
		subheader.Text = "CLICK " .. v15 - count .. " TIMES TO OPEN"

		if count == 1 then
			PackOpenHandler.YVectorTween(0, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		end

		if count == v15 then
			subheader.Visible = false
			Visuals.Play(v13, nil, false)
			Visuals.Recolour(v11, colour.Keypoints[1].Value)
			ContextActionService:UnbindAction("TapAction")
			owned.Text = p2 - p .. "x"
			CFrameHelper.TweenCFrame(v6, CFrame.Angles(0, 0, 0), TweenInfo.new(0.1), function(_, p4)
				v6 = p4
			end)

			TweenService:Create(
				v14,
				TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, true, 0),
				{ FillTransparency = 0.2 }
			):Play()

			PackOpenHandler.LookVectorTween(
				1.2,
				TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, true, 0)
			)
			task.spawn(function()
				task.wait(0.25)
				PackOpenHandler.YVectorTween(
					-2,
					TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0)
				)
				ModelHelper:Transparency(clone, 0.5, 1)
			end)
			Sounds.Play(Sounds.new({ "PackOpening", "Final" }, nil), nil, true)

			Sounds.Play(Sounds.new({ "Feel", "Loot", rarity2 }, nil), nil, true)
			itemName.Text = v10.item
			uiGradient.Color = Colours[rarity2]
			rarity.Text = "[ 1/" .. v10.chance .. " ] chance"

			require((ReplicatedStorage.Assets.Packs:FindFirstChild(childName)))

			local child2 = Display:FindFirstChild(packType)

			if child2 then
				local module2 = require(child2)
				module2(v10)
			end

			task.wait(v9 and 1 or 1.5)

			OnPackOpenFinished:Fire()
		else
			v3:ShakeOnce(2, 7, 0.1, 0.1, Vector3.new(0, 0.2, 0), Vector3.new(1, 1, 1) * (count % 2 == 0 and -1 or 1))
			Visuals.Play(v12, nil, false)
			TweenService:Create(
				v14,
				TweenInfo.new(0.1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, true, 0),
				{ FillTransparency = 0.8 }
			):Play()
			local v16 = 20 * (count % 2 == 1 and 1 or -1)
			CFrameHelper.TweenCFrame(v6, CFrame.Angles(0, 0, (math.rad(v16))), TweenInfo.new(0.2), function(_, p4)
				v6 = p4
			end)

			local v17 = Sounds.new({ "PackOpening", "Hit" }, nil)
			Sounds.SetPitch(v17, Random.new():NextNumber(0.9, 1.1))
			Sounds.SetDistortion(v17, Random.new():NextNumber(0, 0.2))
			Sounds.Play(v17, nil, true)
		end
	end

	if PackOpenConfiguration.AUTO_OPEN then
		for _ = 1, 3 do
			task.wait(0.5)
			onTap("TapAction", Enum.UserInputState.Begin, nil)
		end
	else
		ContextActionService:BindAction(
			"TapAction",
			onTap,
			false,
			Enum.UserInputType.MouseButton1,
			Enum.UserInputType.Touch,
			Enum.KeyCode.ButtonR2
		)
	end

	OnPackOpenFinished.Event:Wait()
end

function PackOpenHandler.LookVectorTween(p, p2)
	numberTween:Start(p, p2)
end

function PackOpenHandler.YVectorTween(p, p2)
	numberTween2:Start(p, p2)
end

function PackOpenHandler:AddToViewport()
	self.Parent = LocalPlayer.Character
	table.insert(v8, self)
end

function PackOpenHandler.GetDisplayMaid()
	return displayMaid
end

function PackOpenHandler.ApplyOutline(parent)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
	highlight.Parent = parent

	displayMaid[HttpService:GenerateGUID()] = highlight

	return highlight
end

return PackOpenHandler