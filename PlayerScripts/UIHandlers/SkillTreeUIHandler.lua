local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local CurrencyHelper = require(ReplicatedStorage.Libraries.Helpers.CurrencyHelper)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local TweenService = game:GetService("TweenService")
local SkillTreeHelper = require(ReplicatedStorage.Libraries.Helpers.SkillTreeHelper)
local SkillTreeConstants = require(ReplicatedStorage.Libraries.Constants.SkillTreeConstants)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
game:GetService("MarketplaceService")
local MonetizationHelper = require(ReplicatedStorage.Libraries.Helpers.MonetizationHelper)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local skillTreeUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("SkillTreeUI")
local background = skillTreeUI.Background
local tree = skillTreeUI.Tree
local Assets = ReplicatedStorage.Assets
local Skill = Assets.InterfaceAssets.SkillTree.Skill
local World = Assets.InterfaceAssets.SkillTree.World

local popup = skillTreeUI.Popup
local _ = { NoGradient = "rbxassetid://80282697081606", Gradient = "rbxassetid://119121546472210" }

local clones = {}
local v2 = "Main"
local visible = false
local scale = 1
local v3 = false
local vector2 = Vector2.new(0, 0)
local v4 = Vector2.new(0, 0)
local v5 = {}

local function setZoom(value: number)
	scale = math.clamp(value, 0.45, 1.8)
	clones[v2].UIScale.Scale = scale
end

local function setWorld(p: string)
	local v6 = v2
	v2 = p

	if v6 then
		clones[v6].Visible = false
	end

	clones[v2].Visible = true
	clones[v2].Position = UDim2.new(0.5, -120, 0.5, 0)

	for k, v7 in v5[v2] do
		local skillTrace = SkillTreeHelper.SkillTrace(k)
		v7.Hex.Size = UDim2.fromScale(0, 0)
		task.spawn(function()
			task.wait((#skillTrace - 1) * 0.15)
			TweenService:Create(v7.Hex, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Size = UDim2.fromScale(1, 1)
			}):Play()
		end)
	end

	scale = 1
	clones[v2].UIScale.Scale = scale
end

local function branchToPixel(p: number, p2: number)
	if p2 == 0 then
		return Vector2.zero
	end

	local v6 = math.rad(p)

	return Vector2.new(math.cos(v6) * 65 * p2, -math.sin(v6) * 65 * p2)
end

local function gridToPixel(vector2_2: Vector2)
	return Vector2.new(vector2_2.X * 150, vector2_2.Y * 150)
end

local function hexToPixel(position: Vector2) -- 1 equivalent call inferred from this helper
	local x = position.X
	local y = position.Y

	local v6 = 65 * (1.7320508075688772 * x + 0.8660254037844386 * y)
	local v7 = 65 * (1.5 * y)

	return Vector2.new(v6, v7)
end

local function updateVisuals()
	for _, v6 in v5 do
		for k, v7 in v6 do
			local skill = SkillTreeHelper.FindSkillById(k)
			local hex = v7:FindFirstChild("Hex")
			local index = table.find(data.skillTree, k)
			local canAfford = CurrencyHelper.CanAfford({ mantissa = skill.cost, exponent = 1 }, data.currency1)
			local hasRequirements = SkillTreeHelper.HasRequirements(userId, skill)

			if index or hasRequirements and canAfford or hasRequirements then
				v7.Hex.Icon.Visible = true
				v7.Hex.Icon.Image = skill.icon
				v7.Hex.Label.FontFace = Font.new(
					"rbxasset://fonts/families/Montserrat.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				)
				v7.Hex.Label.Text = skill.name
				v7.Hex.Label.Position = UDim2.fromScale(0.5, 0.55)
				v7.Hex.Label.Size = UDim2.fromScale(0.7, 0.2)
				v7.Hex.Price.Text = "$" .. NumberHelper:Separate(skill.cost)
				v7.Hex.Price.TextColor3 = CurrencyHelper.CanAfford(
						{ mantissa = skill.cost, exponent = 1 },
						data.currency1
					)
					and Color3.fromRGB(255, 255, 139)
					or Color3.fromRGB(255, 90, 90)

				if skill.buttonType == "Menu" then
					hex.Price.Visible = false
					hex.ImageColor3 = SkillTreeConstants.SKILL_TREE_COLOURS.Menu
				elseif skill.buttonType == "Gamepass" then
					local productInfo = MonetizationHelper.GetProductInfo(tonumber(k), Enum.InfoType.GamePass)

					if not MonetizationHelper.UserOwnsGamepass(userId, (tonumber(k))) then
						if productInfo then
							v7.Hex.Price.Text = productInfo.PriceInRobux
						end

						v7.Hex.Price.TextColor3 = Color3.fromRGB(255, 255, 255)
					end

					hex.ImageColor3 = SkillTreeConstants.SKILL_TREE_COLOURS.Gamepass
				elseif index then
					hex.Price.Visible = false
					hex.ImageColor3 = SkillTreeConstants.SKILL_TREE_COLOURS.Unlocked
				elseif hasRequirements then
					hex.Price.Visible = true
					hex.ImageColor3 = SkillTreeConstants.SKILL_TREE_COLOURS.CanAfford
				end

				v7.Visible = true
			else
				local v8 = SkillTreeHelper.SkillTrace(k)[2]
				local skill2 = SkillTreeHelper.FindSkillById(v8)

				if SkillTreeHelper.HasRequirements(userId, skill2) then
					v7.Hex.Label.Position = UDim2.fromScale(0.5, 0.5)
					v7.Hex.Label.Size = UDim2.fromScale(1, 0.6)
					v7.Hex.Label.FontFace = Font.new(
						"rbxasset://fonts/families/DenkOne.json",
						Enum.FontWeight.Regular,
						Enum.FontStyle.Normal
					)

					v7.Hex.Label.Text = "?"
					v7.Hex.Icon.Visible = false
					hex.Price.Visible = false
					hex.ImageColor3 = SkillTreeConstants.SKILL_TREE_COLOURS.Locked
					v7.Visible = true
				else
					v7.Visible = false
				end
			end
		end
	end
end

local v6 = nil

local function createHexagonButton(k: string, data2, k2: string)
	local v7 = hexToPixel(data2.position) -- inferred equivalent call
	local clone = Skill:Clone()
	clone.Position = UDim2.fromOffset(2000 + v7.X, 2000 + v7.Y)
	clone.Hex.Icon.Image = data2.icon
	clone.Hex.Label.Text = data2.name
	clone.Hex.Price.Text = NumberHelper:Separate(data2.cost)
	clone.Hex.Price.TextColor3 = CurrencyHelper.CanAfford({ mantissa = data2.cost, exponent = 1 }, data.currency1)
		and Color3.fromRGB(255, 255, 255)
		or Color3.fromRGB(255, 0, 0)
	clone.Parent = clones[k2]

	clone.Button.MouseEnter:Connect(function()
		local index = table.find(data.skillTree, k)
		local canAfford = CurrencyHelper.CanAfford({ mantissa = data2.cost, exponent = 1 }, data.currency1)
		local hasRequirements = SkillTreeHelper.HasRequirements(userId, data2)

		if not (index or hasRequirements and canAfford or hasRequirements) then
			return
		end

		v6 = k
		UserInterfaceHelper.FollowMouse(popup)

		popup.Visible = true
		popup.Description.Text = data2.description
		popup.Header.Text = data2.name
		popup.Price.Text = "$" .. NumberHelper:Separate(data2.cost)
		popup.Price.Visible = not index
		local canAfford2 = CurrencyHelper.CanAfford({ mantissa = data2.cost, exponent = 1 }, data.currency1)
		popup.Price.TextColor3 = canAfford2 and Color3.fromRGB(255, 255, 139) or Color3.fromRGB(255, 90, 90)
		TweenService:Create(clone.Hex, TweenInfo.new(0.25), { Size = UDim2.fromScale(1.1, 1.1) }):Play()
	end)
	clone.Button.MouseLeave:Connect(function()
		if not (v6 and v6 == k) then
			return
		end

		popup.Visible = false
		UserInterfaceHelper.StopFollowMouse(popup)
		TweenService:Create(clone.Hex, TweenInfo.new(0.25), { Size = UDim2.fromScale(1, 1) }):Play()
	end)

	local buttonType = SkillTreeHelper.FindSkillById(k).buttonType

	Button.Create(clone, function()
		local v8 = vector2 - v4

		if v8.X == 0 and v8.Y == 0 then
			if buttonType == "Button" then
				RemoteSignals.FireServer("SkillTree", "SkillTreeUnlock", k)
			elseif buttonType == "Menu" then
				setWorld(k)
			elseif buttonType == "Gamepass" then
				Sales.Prompt(userId, tonumber(k), Enum.InfoType.GamePass)
			end
		end
	end)

	if not v5[k2] then
		v5[k2] = {}
	end

	v5[k2][k] = clone

	if buttonType == "Gamepass" then
		UserInterfaceHelper.AlignFrameToText(clone.Hex.Price, clone.Hex.RobuxIcon, {
			iconSize = 1,
			padding = 0
		})
	else
		clone.Hex.RobuxIcon:Destroy()
	end
end

local function beginDrag(input) -- 1 equivalent call inferred from this helper
	v3 = true
	vector2 = Vector2.new(input.Position.X, input.Position.Y)
	v4 = Vector2.new(input.Position.X, input.Position.Y)
	visible = popup.Visible
end

local function endDrag() -- 1 equivalent call inferred from this helper
	popup.Visible = visible
	v3 = false
	vector2 = Vector2.new(0, 0)
	v4 = Vector2.new(0, 0)
end

local function updateDrag(p)
	if not (v3 and v4) then
		return
	end

	local vector2_2 = Vector2.new(p.Position.X, p.Position.Y)
	local v7 = vector2_2 - v4
	v4 = vector2_2

	clones[v2].Position += UDim2.fromOffset(v7.X, v7.Y)
	popup.Visible = false
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		beginDrag(input) -- inferred equivalent call
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		endDrag() -- inferred equivalent call
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		if input.Position.Z > 0 then
			scale = math.clamp(scale + 0.1, 0.45, 1.8)
		else
			scale = math.clamp(scale - 0.1, 0.45, 1.8)
		end

		clones[v2].UIScale.Scale = scale
	elseif
		(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		and v3
	then
		if not v4 then
			return
		end

		local vector2_2 = Vector2.new(input.Position.X, input.Position.Y)
		local v7 = vector2_2 - v4
		v4 = vector2_2

		clones[v2].Position += UDim2.fromOffset(v7.X, v7.Y)
		popup.Visible = false
	end
end)

UserInputService.TouchPinch:Connect(function(_, p: number, _: number, p2)
	if p2 == Enum.UserInputState.Change then
		scale = math.clamp(scale * p, 0.45, 1.8)
		clones[v2].UIScale.Scale = scale
	end
end)

for k, v7 in SkillTreeConstants.SKILL_TREES do
	local clone = World:Clone()
	clone.Name = k
	clone.Parent = skillTreeUI.Tree
	clone.Visible = false
	clones[k] = clone

	for k2, v8 in v7 do
		createHexagonButton(k2, v8, k)
	end
end

updateVisuals()
v:ListenToWrite("SkillTree", updateVisuals)

Menu.Opened:Connect(function(p: string)
	if p ~= "SkillTree" then
		return
	end

	setWorld(v2)
end)