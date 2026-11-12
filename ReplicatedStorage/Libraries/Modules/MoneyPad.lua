local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.DataTypes)

local isServer = RunService:IsServer()

local function _add(instance)
	print("Adding: ", instance)
	local button = instance:FindFirstChild("Button")
	local sign = instance:FindFirstChild("Sign")
	local surfaceGui = sign:FindFirstChild("SurfaceGui")
	local topLabel = surfaceGui:FindFirstChild("TopLabel")
	local bottomLabel = surfaceGui:FindFirstChild("BottomLabel")

	print(button, sign, surfaceGui, topLabel, bottomLabel)

	if not (button and sign and surfaceGui and topLabel) then
		return
	end

	if not bottomLabel then
		return
	end

	if isServer then
		button.Touched:Connect(function(otherPart)
			local parent = otherPart.Parent
			local playerFromCharacter = parent and Players:GetPlayerFromCharacter(parent)

			if not playerFromCharacter then
				return
			end

			local userId = tostring(playerFromCharacter.UserId)
			local v = userId and Profiles.GetPlayerReplica(userId)
			local data = v.Data

			if not (v and data.group) then
				return
			end

			if not data.rewardClaims.FreeMoney or os.time() - data.rewardClaims.FreeMoney > 600 then
				v:Write("RewardClaims", "FreeMoney", os.time())
				v:Write("Currency1", { mantissa = 1000, exponent = 0 })
			end
		end)
		return
	end

	local userId = tostring(Players.LocalPlayer.UserId)
	local data = (userId and Profiles.GetPlayerReplica(userId)).Data

	task.spawn(function()
		while instance and topLabel:IsDescendantOf(workspace) do
			if data.rewardClaims.FreeMoney and not (os.time() - data.rewardClaims.FreeMoney > 600) then
				topLabel.Text = NumberHelper.FormatTimerMS(600 - (os.time() - data.rewardClaims.FreeMoney))
			else
				topLabel.Text = "Free money every 10 minutes!"
			end

			task.wait(1)
		end
	end)
end

local MoneyPad = {}

function MoneyPad.Init()
	print("Money pad init called")

	for _, v in CollectionService:GetTagged("MoneyPad"), nil, nil do
		_add(v)
	end

	CollectionService:GetInstanceAddedSignal("MoneyPad"):Connect(_add)
end

function MoneyPad.Add(instance)
	CollectionService:AddTag(instance, "MoneyPad")
end

return MoneyPad