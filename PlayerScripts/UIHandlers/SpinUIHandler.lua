local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Modules.Menu)
local SharedConstants = require(ReplicatedStorage.Libraries.Constants.SharedConstants)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
require(ReplicatedStorage.Libraries.Classes.Notifications)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
require(ReplicatedStorage.Libraries.Modules.Sales)
game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Inventories = require(ReplicatedStorage.Libraries.Classes.Inventories)
require(ReplicatedStorage.Libraries.Modules.ClientSounds)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local spinUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("SpinUI")
local handle = spinUI.Handle
local spinner = spinUI.Spinner
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local Assets = ReplicatedStorage.Assets
local Glow = Assets.InterfaceAssets.Spin.Glow
local SelectedGradient = Assets.InterfaceAssets.Spin.SelectedGradient
local spin = spinUI.Buttons.Spin
local v2 = Maid.new()

local flipKeyValue = TableHelper.FlipKeyValue(MonetizationConstants.PRODUCT_IDS.SPINS_RATES)

local function init()
	for _, child in spinUI.BuySpins:GetChildren(), nil, nil do
		if flipKeyValue[tonumber(child.Name)] then
			child.Name = flipKeyValue[tonumber(child.Name)]
		end
	end
end

init()

function getIndex(p: number)
	local v3 = math.floor((p - 22.5) % 360 / 45)

	return v3 == 0 and 8 or v3
end

local v3 = nil
local v4 = { "SpinWheel" }

for childName, drop in SharedConstants.SPIN_WHEEL_INFO.drops do
	local findFirstChild = spinner:FindFirstChild(childName)
	findFirstChild.Segment.Percentage.Text = drop.percentage .. "%"
	local v5 = Inventories.fromList({}, spinner:FindFirstChild(childName).Segment.Icon, "misc", "v1")

	Inventories.AddList(v5, {
		["Item" .. childName] = drop
	})

	local slot = v5.slots["Item" .. childName]
	slot.Rotation = 90
	local background = slot.Content.Background

	slot.Content.Shine.Visible = false
	slot.Content.Background.UIStroke.Transparency = 1

	if background:IsA("ImageLabel") then
		slot.Content.Background.ImageTransparency = 1
	elseif background:IsA("Frame") then
		slot.Content.Background.BackgroundTransparency = 1
	end
end

local v5 = true

Button.Create(spin, function()
	if data.spins <= 0 or not v5 then
		return
	end

	v5 = false
	RemoteSignals.FireServer("SpinWheel", "SpinWheel")
end)

spin.Content.Label.Text = "SPIN [ " .. data.spins .. " ]"
v:ListenToWrite("Spins", function()
	spin.Content.Label.Text = "SPIN [ " .. data.spins .. " ]"
end)

Button.Create(spinUI.Info, function()
	for _, descendant in spinUI.Spinner:GetDescendants(), nil, nil do
		if descendant.Name == "Percentage" then
			descendant.Visible = not descendant.Visible
		end
	end
end)

local function stopHighlight()
	if not v3 then
		return
	end

	local child = spinner:FindFirstChild(v3)

	if not child then
		return
	end

	v3 = nil

	TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(1, 1)
	}):Play()

	child.Segment.UIGradient.Enabled = true
	Glow.Parent = script
	SelectedGradient.Parent = script
end

local function highlight(p)
	if p == v3 then
		return
	end

	stopHighlight()
	v3 = p
	local v6 = spinner[p]

	TweenService:Create(v6, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(1.2, 1.2)
	}):Play()

	v6.Segment.UIGradient.Enabled = false
	SelectedGradient.Parent = v6.Segment
	Glow.Parent = v6.Segment
end

RemoteSignals.OnClientEvent("SpinWheel", function(p, ...)
	if not table.find(v4, p) then
		return
	end

	stopHighlight()
	handle.Visible = true
	v2.idleSpin = nil
	spinner.Rotation = 0

	local v6 = ({ ... })[1]
	local _ = SharedConstants.SPIN_WHEEL_INFO.drops[v6]
	local v7 = SharedConstants.SPIN_WHEEL_INFO.angle[v6]

	local v8 = v7[1] - 5
	local v9 = v7[2] + 5
	local v10 = math.clamp(Random.new():NextNumber(v7[1], v7[2]), v9, v8) + -1440
	local v11 = 0
	local count = 0
	local total = 0

	while v10 < -1.5 do
		local v12 = (spinner.Rotation + 22.5) % 45

		if v12 < v11 then
			count += 1
			Sounds.Play(Sounds.new({ "UserInterface", "SpinTick" }, nil), nil, true)

			local v13 = count

			TweenService:Create(handle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Rotation = -30
			}):Play()

			task.spawn(function()
				task.wait(0.1)

				if v13 == count then
					TweenService:Create(handle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Rotation = 0
					}):Play()
				end
			end)
		end

		local v13 = v10 / 100
		spinner.Rotation -= v13
		v10 -= v13
		total += v13
		task.wait()
		v11 = v12
	end

	local v12 = -1440 + (v7[1] + v7[2]) / 2

	TweenService:Create(spinner, TweenInfo.new(1.5, Enum.EasingStyle.Elastic), {
		Rotation = math.abs(v12)
	}):Play()

	handle.Visible = false
	highlight(getIndex(total))
	Sounds.Play(Sounds.new({ "Hard" }, nil), nil, true)

	task.wait(1.5)
	stopHighlight()
	v2.idleSpin = RunService.Heartbeat:Connect(function(dt: number)
		spinner.Rotation += dt * 30
	end)
	v5 = true
end)

v2.idleSpin = RunService.Heartbeat:Connect(function(dt: number)
	spinner.Rotation += dt * 30
end)