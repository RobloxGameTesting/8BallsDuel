local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolCardRewards = require(Pool.PoolCardRewards)
local PoolConstants = require(Pool.PoolConstants)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolSkins = require(Pool.PoolSkins)

local Menu = PoolConstants.Menu

local v = {
	Normal = "COMMON",
	Tier1 = "COMMON",
	Tier2 = "UNCOMMON",
	Tier3 = "RARE",
	Tier4 = "EPIC",
	Tier5 = "LEGENDARY",
	Tier6 = "MYTHIC",
	Tier7 = "MYTHIC"
}

local v2 = { cueSticks = "CUE STICK", poolTables = "POOL TABLE", poolEffects = "POT EFFECT" }

local v3 = {
	Wood = { Color3.fromRGB(222, 170, 118), Color3.fromRGB(160, 106, 60), Color3.fromRGB(92, 56, 28) },
	Silver = { Color3.fromRGB(250, 252, 255), Color3.fromRGB(186, 198, 214), Color3.fromRGB(110, 124, 146) },
	Gold = { Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 196, 56), Color3.fromRGB(190, 116, 16) },
	First = { Color3.fromRGB(244, 186, 255), Color3.fromRGB(176, 84, 236), Color3.fromRGB(86, 28, 150) }
}

local function cardArt(value: string?, p: string) -- 4 equivalent calls inferred from this helper
	if typeof(value) == "string" and value ~= "" then
		return value
	end

	local studioFolder = PoolConstants.CardArt.StudioFolder

	if RunService:IsStudio() and typeof(studioFolder) == "string" then
		return studioFolder .. p
	end

	return nil
end

local function backArt(p: string) -- 1 equivalent call inferred from this helper
	return cardArt(PoolConstants.CardArt.Backs[p], "CardBack_" .. p .. ".png") -- inferred equivalent call
end

local function frontArt(flag: boolean)
	if flag then
		local v4 = cardArt(PoolConstants.CardArt.FrontCoins, "CardFront_Coins.png") -- inferred equivalent call

		if v4 then
			return v4, "FrontCoins"
		end
	end

	return cardArt(PoolConstants.CardArt.Front, "CardFront.png"), "Front" -- inferred equivalent call
end

local color = Color3.fromRGB(120, 215, 255)
local color2 = Color3.fromRGB(40, 120, 220)

local function rewardGems(p) -- 2 equivalent calls inferred from this helper
	if typeof(p) == "table" then
		return tonumber(p.Gems) or 0
	end

	return 0
end

local color3 = Color3.fromRGB(125, 125, 140)

local flag = false

local poolCardPickUI = nil

local function getTemplate(playerGui) -- 1 equivalent call inferred from this helper
	if not poolCardPickUI then
		poolCardPickUI = playerGui:FindFirstChild("PoolCardPickUI")
			or ReplicatedStorage.UI:FindFirstChild("PoolCardPickUI")
			or playerGui:WaitForChild("PoolCardPickUI")
	end

	return poolCardPickUI
end

local function tween(instance, duration: number, goal, p, p2) -- 3 equivalent calls inferred from this helper
	local tween2 = TweenService:Create(
		instance,
		TweenInfo.new(duration, p or Enum.EasingStyle.Quad, p2 or Enum.EasingDirection.Out),
		goal
	)

	tween2:Play()

	return tween2
end

local function rarityOf(p)
	local result = p and p.rarity

	if typeof(result) == "function" then
		local success
		success, result = pcall(result, {}, p)

		if not success then
			result = nil
		end
	end

	return if typeof(result) == "string" then result else "Tier1"
end

local function rarityColour(p: string) -- 2 equivalent calls inferred from this helper
	local rarityData = Rarities.GetRarityData(p)
	local keypoints = rarityData and rarityData.colour and rarityData.colour.Keypoints

	if keypoints and keypoints[#keypoints] then
		return keypoints[#keypoints].Value
	end

	return Menu.Gold
end

local function rarityGradient(p: string) -- 1 equivalent call inferred from this helper
	local rarityData = Rarities.GetRarityData(p)

	if rarityData and rarityData.colour then
		return rarityData.colour
	end

	return (ColorSequence.new(Menu.GoldShade, Menu.Gold))
end

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolCardPickScreen: %s.%s is missing (looking for %q)",
					instance:GetFullName(),
					value,
					childName
				),
				2
			)
		end
	end

	return child
end

local function coinsText(coins: number) -- 6 equivalent calls inferred from this helper
	return "+" .. NumberHelper:Separate((math.floor(coins)))
end

local function rewardItem(p) -- 2 equivalent calls inferred from this helper
	if typeof(p) == "table" and typeof(p.Category) == "string" and typeof(p.Item) == "string" then
		return PoolSkins.GetItem(p.Category, p.Item)
	end

	return nil
end

local function useArt(instance, value: string?, items, p)
	local art = instance:FindFirstChild("Art")
	local visible

	if value == nil or art == nil then
		visible = false
	else
		visible = art:IsA("ImageLabel")
	end

	if art and art:IsA("ImageLabel") then
		art.Image = value or ""
		art.Visible = visible
	end

	instance.BackgroundTransparency = visible and 1 or 0

	if p then
		p.Enabled = not visible
	end

	for _, item in items do
		item.Visible = not visible
	end

	return visible
end

local function bindCard(p, p2: number, list, p3: string)
	local slot = bind(p, "Row.Slot" .. p2)
	local button = bind(slot, "Card")
	local back = bind(button, "Back")

	useArt(back, backArt(p3), { bind(back, "Inset"), bind(back, "Mark") }, back:FindFirstChildOfClass("UIStroke")) -- inferred equivalent call

	back.BackgroundColor3 = list[2]

	local bind_2 = bind(back, "UIGradient")
	bind_2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, list[1]),
		ColorSequenceKeypoint.new(0.5, list[2]),
		ColorSequenceKeypoint.new(1, list[3])
	})

	local bind_3 = bind(back, "Inset.UIStroke")
	bind_3.Color = list[1]

	local v4 = bind(back, "Hint")
	v4.Visible = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled

	v4.TextColor3 = list[1]

	return {
		Slot = slot,
		Button = button,
		Scale = bind(button, "UIScale"),
		Back = back,
		Front = bind(button, "Front"),
		Rays = bind(p, "RayLayer.Rays" .. p2),
		Index = p2
	}
end

local v4 = { "Glow", "Coin", "Icon", "Glyph", "Preview" }

local function place(p, list) -- 5 equivalent calls inferred from this helper
	if not list then
		return
	end

	p.Position = UDim2.fromScale(list[1], list[2])

	if list[3] and list[4] then
		p.Size = UDim2.fromScale(list[3], list[4])
	end
end

local function layOutOnArt(front, p: string, flag2: boolean)
	local faces = PoolConstants.CardArt.Faces
	local v5

	if typeof(faces) == "table" then
		v5 = faces[p]
	end

	if typeof(v5) ~= "table" then
		return
	end

	place(bind(front, "Band"), v5.Rarity) -- inferred equivalent call

	local bind_2 = bind(front, "Band.Rarity")
	bind_2.Size = UDim2.fromScale(1, 1)

	if v5.Picture then
		for _, v6 in v4 do
			place(bind(front, v6), { v5.Picture[1], v5.Picture[2] }) -- inferred equivalent call
		end
	end

	local v6 = bind(front, "ItemName")
	local v7 = if flag2 then v5.NameWithKind else v5.Name
	place(v6, v7) -- inferred equivalent call
	place(bind(front, "Kind"), v5.Kind) -- inferred equivalent call
	place(bind(front, "Tag"), v5.Tag) -- inferred equivalent call
end

local function fillFront(p, data, text: string, textColor: Color3)
	local front = p.Front
	local v5 = rewardItem(data) -- inferred equivalent call
	local v6 = rewardGems(data) -- inferred equivalent call
	local v7

	if v5 == nil then
		v7 = v6 > 0
	else
		v7 = false
	end

	local v8

	if v5 == nil then
		v8 = not v7
	else
		v8 = false
	end

	local v9 = not v5 and "Tier5" or rarityOf(v5)
	local v10

	if v7 then
		v10 = color
	elseif v8 then
		v10 = Menu.Gold
	else
		v10 = rarityColour(v9) -- inferred equivalent call
	end

	local v11 = bind(front, "Border")
	v11.Color = v10

	local v12 = bind(front, "Band")
	local v13 = bind(front, "Band.UIGradient")
	local color4

	if v7 then
		color4 = ColorSequence.new(color2, color)
	elseif v8 then
		color4 = ColorSequence.new(Menu.GoldShade, Menu.Gold)
	else
		color4 = rarityGradient(v9) -- inferred equivalent call
	end

	v13.Color = color4
	local v14, v15, studioFolder

	if v8 then
		v14 = PoolConstants.CardArt.FrontCoins
		v14 = cardArt(v14, "CardFront_Coins.png") -- inferred equivalent call

		if v14 then
			v15 = "FrontCoins"
		else
			v14 = PoolConstants.CardArt.Front

			if typeof(v14) ~= "string" or v14 == "" then
				studioFolder = PoolConstants.CardArt.StudioFolder

				if RunService:IsStudio() and typeof(studioFolder) == "string" then
					v14 = studioFolder .. "CardFront.png"
				else
					v14 = nil
				end
			end

			v15 = "Front"
		end
	else
		v14 = PoolConstants.CardArt.Front

		if typeof(v14) ~= "string" or v14 == "" then
			studioFolder = PoolConstants.CardArt.StudioFolder

			if RunService:IsStudio() and typeof(studioFolder) == "string" then
				v14 = studioFolder .. "CardFront.png"
			else
				v14 = nil
			end
		end

		v15 = "Front"
	end

	local v16 = useArt(front, v14, {}, v11)

	v12.BackgroundTransparency = v16 and 1 or 0

	local v17 = bind(front, "Band.Rarity")
	v17.Text = v7 and "GEMS" or v8 and "COINS" or v[v9] or string.upper(v9)
	local textColor2

	if v16 and not (v8 or v7) then
		textColor2 = v10
	else
		textColor2 = Color3.new(1, 1, 1)
	end

	v17.TextColor3 = textColor2

	local bind_2 = bind(front, "Glow")
	bind_2.BackgroundColor3 = v10

	local v18 = bind(front, "Coin")
	local v19 = bind(front, "Icon")
	local v20 = bind(front, "Glyph")
	local v21 = bind(front, "Preview")

	v18.Visible = false
	v19.Visible = false
	v20.Visible = false
	v21.Visible = false

	local text2 = ""
	local text3

	if v7 then
		v19.Image = "rbxassetid://91068843812037"
		v19.Visible = true
		text3 = "+" .. NumberHelper:Separate(v6)
	elseif v8 then
		v18.Visible = true
		text3 = coinsText(tonumber(data and data.Coins) or 0) -- inferred equivalent call
	else
		text3 = string.upper((tostring(v5.name or data.Item)))
		text2 = v2[data.Category] or ""

		local image = typeof(v5.image) ~= "string" and "" or v5.image

		if data.Category == "poolEffects" then
			if image == "" then
				if typeof(v5.colour) == "Color3" then
					v10 = v5.colour
				end

				v20.TextColor3 = v10
				v20.Visible = true
			else
				v19.Image = image
				v19.Visible = true
			end
		else
			v21.Visible = true

			local skinModel = PoolMenuWidgets.FindSkinModel(v5)

			if data.Category == "cueSticks" then
				PoolMenuWidgets.CuePreview(v21, skinModel)
			else
				PoolMenuWidgets.ModelPreview(v21, skinModel)
			end
		end
	end

	local v22 = bind(front, "ItemName")
	v22.Text = text3
	local textColor3

	if v7 then
		textColor3 = color
	else
		textColor3 = if v8 then Menu.Gold else Menu.TextPrimary
	end

	v22.TextColor3 = textColor3

	local bind_3 = bind(front, "Kind")
	bind_3.Text = text2

	if v16 then
		layOutOnArt(front, v15, text2 ~= "")
	end

	local v23 = bind(front, "Tag")
	v23.Text = text

	if v16 and (textColor == Menu.Gold or textColor == Menu.TextMuted) then
		textColor = Color3.new(1, 1, 1)
	end

	v23.TextColor3 = textColor

	for _, label in front:GetDescendants() do
		if label:IsA("TextLabel") then
			label.TextTransparency = 0
		end
	end

	for _, instance in { front:FindFirstChild("Art"), v18, v19, v21 } do
		if instance and (instance:IsA("ImageLabel") or instance:IsA("ViewportFrame")) then
			instance.ImageColor3 = Color3.new(1, 1, 1)
		end
	end
end

local function flip(data, visible: boolean)
	tween(data.Button, 0.16, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Wait() -- inferred equivalent call

	data.Back.Visible = not visible
	data.Front.Visible = visible

	tween(data.Button, 0.26, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out).Completed:Wait() -- inferred equivalent call
end

local function dim(p)
	TweenService:Create(p.Scale, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 0.9
	}):Play()

	local front = p.Front
	local art = front:FindFirstChild("Art")

	if art and art:IsA("ImageLabel") and art.Visible then
		for _, childName in { "Art", "Coin", "Icon", "Preview" } do
			local instance = front:FindFirstChild(childName)

			if instance and (instance:IsA("ImageLabel") or instance:IsA("ViewportFrame")) then
				TweenService:Create(instance, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = color3
				}):Play()
			end
		end

		for _, label in front:GetDescendants() do
			if label:IsA("TextLabel") then
				TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0.3
				}):Play()
			end
		end

		TweenService:Create(bind(front, "Glow"), TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.92
		}):Play()
	else
		local v5 = bind(front, "Dim")
		v5.BackgroundTransparency = 1
		v5.Visible = true
		TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.45
		}):Play()
	end
end

local PoolCardPickScreen = {}

function PoolCardPickScreen.IsOpen()
	return flag
end

function PoolCardPickScreen:Play()
	if flag then
		return false, false
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false, false
	end

	flag = true

	local v5 = PoolCardRewards.GetTier(self.Tier) or PoolCardRewards.Tiers[1]
	local v6 = v5.Id ~= "Wood"

	local v7 = v5.ItemChance <= 0
	local v8

	if self.First then
		v8 = "First"
	elseif v7 then
		v8 = "Gold"
	else
		v8 = if not v3[v5.Id] then "Wood" else v5.Id
	end

	local v9 = v3[v8] or v3.Wood

	local maid = Maid.new()
	local selectedObject = GuiService.SelectedObject

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local poolCardPickOpen = getTemplate(playerGui):Clone() -- inferred equivalent call
	poolCardPickOpen.Name = "PoolCardPickOpen"
	poolCardPickOpen.Enabled = true
	maid:GiveTask(poolCardPickOpen)

	local v10 = bind(poolCardPickOpen, "Dimmer")
	v10.BackgroundTransparency = 1

	local v11 = bind(poolCardPickOpen, "Content")
	local v12 = bind(v11, "UIScale")
	v12.Scale = 0.9

	local text = self.First and "PICK A CARD TO UNLOCK A CUE STICK" or v6 and "YOU WON! PICK A CARD" or "PICK A CARD"

	local text2 = self.First and "Your first card is always a cue stick"
		or v7
		and (v6 and "Coins or Gems — 1 in 5 cards is a blue Gem card!" or "Coins or Gems — winning makes coin cards 5x bigger")
		or v5.Id == "Gold" and "GOLD CARDS — coins and a guaranteed cue, table or effect"
		or not v6 and "WOOD CARDS — win matches for better cards"
		or v5.Name .. " CARDS — coins and a chance at a cue, table or effect"

	local v13 = bind(v11, "Title")
	v13.Text = text
	local textColor = if self.First then v9[1] else Menu.Gold
	v13.TextColor3 = textColor

	local v14 = bind(v11, "Subtitle")
	v14.Text = text2

	local v15 = { bindCard(v11, 1, v9, v8), bindCard(v11, 2, v9, v8), (bindCard(v11, 3, v9, v8)) }

	local selectedObject3 = bind(v11, "Continue")
	selectedObject3.Visible = false
	local v16 = bind(selectedObject3, "Top")

	local selectionImageObject = bind(poolCardPickOpen, "SelectionImage")
	selectionImageObject.Visible = true
	selectionImageObject.Parent = nil
	maid:GiveTask(selectionImageObject)

	for _, v17 in v15 do
		v17.Button.SelectionImageObject = selectionImageObject
	end

	selectedObject3.SelectionImageObject = selectionImageObject

	poolCardPickOpen.Parent = playerGui

	PoolAudio.PlayCue("MenuOpen")
	TweenService:Create(v10, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.18
	}):Play()
	local back = Enum.EasingStyle.Back
	TweenService:Create(v12, TweenInfo.new(0.35, back or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()

	local function selectForGamepad(selectedObject2) -- 2 equivalent calls inferred from this helper
		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = selectedObject2
		end
	end

	selectForGamepad(v15[2].Button) -- inferred equivalent call

	local v17 = "choosing"
	local v18 = nil
	local v19 = nil
	local v20 = false
	local v21 = false
	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local total = 0

	maid:GiveTask(RunService.RenderStepped:Connect(function(dt: number)
		total += dt

		if v17 == "choosing" and self.KeepOpen then
			local success, result = pcall(self.KeepOpen)

			if success and not result then
				v21 = true
				v17 = "closing"
				bindableEvent:Fire()

				return
			end
		end

		for _, v22 in v15 do
			if v17 == "choosing" then
				local v23 = math.sin(total * 2.2 + v22.Index * 1.3) * 0.018 + 1
				local v24 = (v19 == v22 or GuiService.SelectedObject == v22.Button) and 0.07 or 0

				v22.Scale.Scale += (v23 + v24 - v22.Scale.Scale) * math.min(dt * 14, 1)
				v22.Button.Rotation = math.sin(total * 1.6 + v22.Index) * 1.5
			elseif v17 == "rolling" and v22 == v18 then
				v22.Button.Rotation = math.sin(total * 38) * 4
			end

			if not v22.Rays.Visible then
				continue
			end

			local absoluteSize = v11.AbsoluteSize
			local absoluteSize2 = v22.Slot.AbsoluteSize

			if absoluteSize.X > 0 and absoluteSize.Y > 0 then
				local v23 = v22.Slot.AbsolutePosition + absoluteSize2 / 2 - v11.AbsolutePosition
				local v24 = absoluteSize2.Y * 2

				v22.Rays.Position = UDim2.fromScale(v23.X / absoluteSize.X, v23.Y / absoluteSize.Y)
				v22.Rays.Size = UDim2.fromScale(v24 / absoluteSize.X, v24 / absoluteSize.Y)
			end

			v22.Rays.Rotation += dt * 25
		end
	end))

	for _, v22 in v15 do
		maid:GiveTask(v22.Button.MouseEnter:Connect(function()
			v19 = v22
		end))

		maid:GiveTask(v22.Button.MouseLeave:Connect(function()
			if v19 == v22 then
				v19 = nil
			end
		end))
	end

	local v22 = nil
	local v23 = nil

	maid:GiveTask(RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, value)
		if v17 ~= "rolling" then
			return
		end

		if p == "CardPicked" and typeof(value) == "table" and typeof(value.Reward) == "table" then
			v22 = value
		elseif p == "CardPickFailed" then
			v23 = typeof(value) ~= "string" and "That card could not be opened" or value
		end
	end))

	local function finish()
		v17 = "done"
		selectedObject3.Visible = true
		selectedObject3.Size = UDim2.fromScale(0.252, 0.084)
		local v24 = { Size = UDim2.fromScale(0.42, 0.14) }
		local back2 = Enum.EasingStyle.Back
		TweenService:Create(
			selectedObject3,
			TweenInfo.new(0.3, back2 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			v24
		):Play()
		selectForGamepad(selectedObject3) -- inferred equivalent call
	end

	local function reveal(data)
		v17 = "rolling"
		v18 = data
		v19 = nil

		for _, v24 in v15 do
			v24.Button.Active = false
			v24.Button.Selectable = false

			if v24 == data then
				continue
			end

			TweenService:Create(v24.Scale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 0.94
			}):Play()
			v24.Button.Rotation = 0
		end

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(poolCardPickOpen) then
			GuiService.SelectedObject = nil
		end

		PoolAudio.PlayCue("CueSoft")
		local scale = data.Scale
		local back2 = Enum.EasingStyle.Back
		TweenService:Create(scale, TweenInfo.new(0.25, back2 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1.1
		}):Play()
		v14.Text = "Opening..."

		RemoteSignals.FireServer(RemoteEnums.Pool, "PickCard")

		local lastTime = os.clock()

		while not v22 and not v23 and os.clock() - lastTime < 10 do
			task.wait()
		end

		local v24 = os.clock() - lastTime

		if v24 < 0.8 then
			task.wait(0.8 - v24)
		end

		v17 = "revealing"
		data.Button.Rotation = 0

		if v22 then
			v20 = true

			local reward = v22.Reward
			local v25 = rewardItem(reward) -- inferred equivalent call
			local coins = tonumber(reward.Coins) or 0
			local v26 = v25 and 0 or rewardGems(reward) -- inferred equivalent call
			local duplicate = reward.Duplicate == true
			local first = v22.First == true
			local v27

			if v25 then
				v27 = rarityColour(rarityOf(v25)) -- inferred equivalent call
			else
				v27 = if v26 > 0 then color else Menu.Gold
			end

			local name

			if v25 then
				name = string.upper((tostring(v25.name or reward.Item)))
			end

			local v28, v29

			if v26 > 0 then
				v28 = Menu.Gold
				v29 = "GEMS"
			elseif v25 then
				if duplicate then
					v29 = "OWNED · " .. coinsText(coins) -- inferred equivalent call

					v28 = Menu.Gold
				else
					if first then
						v29 = not (coins > 0) and "EQUIPPED!" or "EQUIPPED · " .. coinsText(coins) -- inferred equivalent call
					else
						v29 = not (coins > 0) and "NEW!" or "NEW · " .. coinsText(coins) -- inferred equivalent call
					end

					v28 = Menu.PlayPrimary
				end
			else
				v28 = Menu.Gold
				v29 = "COINS"
			end

			fillFront(data, reward, v29, v28)
			flip(data, true)

			data.Rays.Visible = true

			for _, frame in data.Rays:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				frame.BackgroundColor3 = v27:Lerp(Menu.Ray, 0.35)
				frame.BackgroundTransparency = 1
				TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0
				}):Play()
			end

			data.Scale.Scale = 1.25
			local scale2 = data.Scale
			local back3 = Enum.EasingStyle.Back
			TweenService:Create(scale2, TweenInfo.new(0.4, back3 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1.12
			}):Play()
			PoolAudio.PlayCue(v25 and "MatchWin" or "PayoutCoin1")

			if v26 > 0 then
				v13.Text = "YOU GOT +" .. NumberHelper:Separate(v26) .. (v26 == 1 and " GEM!" or " GEMS!")
				v13.TextColor3 = color
				v14.Text = "A blue card! Spend Gems on cues in the shop"
			elseif v25 then
				v13.Text = (first and "YOU UNLOCKED " or "YOU GOT ") .. name .. "!"
				v13.TextColor3 = v27:Lerp(Color3.new(1, 1, 1), 0.25)
				v14.Text = not duplicate
					and (first and "It's equipped and ready for your next match" or "Find it in your inventory")
					or "You already own it, so it paid " .. coinsText(coins) .. " coins instead" -- inferred equivalent call
			else
				v13.Text = "YOU GOT " .. coinsText(coins) .. " COINS!" -- inferred equivalent call
				v13.TextColor3 = Menu.Gold

				v14.Text = v6 and "Higher venues pay bigger cards" or "Win your next match for a 5x bigger card"
			end

			task.wait(1.1)

			local v30 = typeof(v22.Others) ~= "table" and {} or v22.Others
			local count = 0

			for _, v31 in v15 do
				if v31 == data then
					continue
				end

				count += 1

				local v32 = v30[count]

				if typeof(v32) ~= "table" then
					continue
				end

				fillFront(v31, v32, "COULD'VE HAD", Menu.TextMuted)
				PoolAudio.PlayCue("CueSoft", 0.6)
				flip(v31, true)
				dim(v31)
				task.wait(0.45)
			end

			finish()
		else
			TweenService:Create(data.Scale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
			v13.Text = "COULDN'T OPEN"
			v14.Text = v23 or "The server didn't answer. Your card is saved for later."
			v16.Text = "CLOSE"
			finish()
		end
	end

	local function pick(index: number) -- 4 equivalent calls inferred from this helper
		if v17 ~= "choosing" then
			return
		end

		local v24 = v15[index]

		if v24 then
			task.spawn(reveal, v24)
		end
	end

	for _, v24 in v15 do
		maid:GiveTask(v24.Button.Activated:Connect(function()
			pick(v24.Index) -- inferred equivalent call
		end))
	end

	local function close()
		if v17 ~= "done" then
			return
		end

		v17 = "closing"
		PoolAudio.PlayCue("MenuOpen")
		TweenService:Create(v10, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		tween(v12, 0.2, { Scale = 0.85 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Wait() -- inferred equivalent call
		bindableEvent:Fire()
	end

	maid:GiveTask(selectedObject3.Activated:Connect(close))

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if v17 == "choosing" and not gameProcessed then
			if input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.KeypadOne then
				pick(1) -- inferred equivalent call
			elseif input.KeyCode == Enum.KeyCode.Two or input.KeyCode == Enum.KeyCode.KeypadTwo then
				pick(2) -- inferred equivalent call
			elseif input.KeyCode == Enum.KeyCode.Three or input.KeyCode == Enum.KeyCode.KeypadThree then
				pick(3) -- inferred equivalent call
			end
		elseif
			v17 == "done"
			and (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonB)
		then
			task.spawn(close)
		end
	end))

	bindableEvent.Event:Wait()

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(poolCardPickOpen) then
		GuiService.SelectedObject = nil
	end

	if selectedObject and selectedObject.Parent and selectedObject.Visible then
		GuiService.SelectedObject = selectedObject
	end

	maid:DoCleaning()
	flag = false

	return v20, v21
end

return PoolCardPickScreen