local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
local CurrencyHelper = require(ReplicatedStorage.Libraries.Helpers.CurrencyHelper)
require(ReplicatedStorage.Types.GameSpecificTypes)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local LeaderstatsHelper = require(ReplicatedStorage.Libraries.Helpers.LeaderstatsHelper)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
Profiles.GetReplica("Game")
local parent = script.Parent
local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local v2 = Maid.new()

local v3 = {}
local sizes = {}

local v4 = {}

local function Lerp(mantissa: number, mantissa2: number, value: number) -- 1 equivalent call inferred from this helper
	return mantissa + (mantissa2 - mantissa) * value
end

local function TweenMoneyLabel(label, p, p2, p3: number) -- 1 equivalent call inferred from this helper
	local total = 0

	v2[label] = RunService.RenderStepped:Connect(function(dt)
		total += dt

		local value = TweenService:GetValue(
			math.clamp(total / p3, 0, 1),
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local exponent = p2.exponent

		local mantissa = p.mantissa

		if p.exponent ~= exponent then
			mantissa /= 1000 ^ (exponent - p.exponent)
		end

		local v5 = {
			mantissa = Lerp(mantissa, p2.mantissa, value), -- inferred equivalent call
			exponent = exponent
		}

		label.Text = CurrencyHelper.FormatMoney(v5)

		if value >= 1 then
			v2[label] = nil
		end
	end)
end

local v5 = {}

local function update(p)
	local v6 = v3[p]

	if not v6 then
		return
	end

	if table.find(v4, p) then
		for _, instance in v6 do
			TweenService:Create(instance, TweenInfo.new(0.2), { Size = UDim2.fromScale(0.6, 1.2) }):Play()
			local instance2 = LeaderstatsHelper.GetValue(LocalPlayer, p)

			if instance2 then
				if instance2:IsA("IntValue") or instance2:IsA("NumberValue") then
					if instance2.Value > 999999 then
						instance.Text = utf8.char(8734)
					else
						instance.Text = `${NumberHelper:Separate(instance2.Value)}`
					end

					task.spawn(function()
						task.wait(0.2)
						TweenService:Create(instance, TweenInfo.new(0.2), {
							Size = UDim2.fromScale(0.5, 0.8)
						}):Play()
					end)
				end
			else
				warn(`Currency {instance2} not found in the leaderstats`)
			end
		end
	else
		local v7 = v5[p]
		local v8 = data[p]
		v5[p] = v8
		local formatMoney = CurrencyHelper.FormatMoney(v8)
		local v9 = ({ currency1 = 1, currency2 = 1 })[p]

		for _, instance in v3[p] do
			if v7 then
				TweenMoneyLabel(instance.Label, v7, v8, v9) -- inferred equivalent call
				TweenService:Create(instance, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Size = sizes[instance] + UDim2.fromScale(0.2, 0.2)
				}):Play()
				instance.Label.Rotation = Random.new():NextInteger(-15, 15)
				TweenService:Create(
					instance.Label,
					TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						Rotation = instance.Label.Rotation * -1
					}
				):Play()

				task.spawn(function()
					task.wait(0.5)
					TweenService:Create(
						instance,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{ Size = sizes[instance] }
					):Play()
					TweenService:Create(
						instance.Label,
						TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{ Rotation = 0 }
					):Play()
				end)
			else
				instance.Label.Text = formatMoney
			end
		end
	end
end

local function tag(p, p2) -- 4 equivalent calls inferred from this helper
	if not v3[p2] then
		v3[p2] = {}
	end

	sizes[p] = p.Size
	table.insert(v3[p2], p)
	update(p2)
end

for _, tag2 in { "Currency1", "Currency2" } do
	local v6 = string.lower(tag2)

	update(v6)
	v:ListenToWrite(tag2, function()
		update(v6)
	end)

	CollectionService:GetInstanceAddedSignal(tag2):Connect(function(p)
		tag(p, v6) -- inferred equivalent call
	end)

	for _, v7 in CollectionService:GetTagged(tag2), nil, nil do
		tag(v7, v6) -- inferred equivalent call
	end
end

for _, v6 in v4 do
	update(v6)
	leaderstats:WaitForChild(v6):GetPropertyChangedSignal("Value"):Connect(function()
		update(v6)
	end)

	CollectionService:GetInstanceAddedSignal(v6):Connect(function(p)
		tag(p, v6) -- inferred equivalent call
	end)

	for _, v7 in CollectionService:GetTagged(v6), nil, nil do
		tag(v7, v6) -- inferred equivalent call
	end
end