local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()
local v = Maid.new()
local Assets = ReplicatedStorage.Assets

local teleportData = nil
local joinData = nil

local v2 = {}
local v3 = { [Enum.TeleportResult.Flooded] = 8, [Enum.TeleportResult.Failure] = 1 }

local TeleportHelper = {}

function TeleportHelper.Init()
	if isServer then
		Players.PlayerAdded:Connect(function(player)
			local joinData2 = player:GetJoinData()

			if not RunService:IsStudio() and joinData2.SourceGameId ~= game.GameId then
				warn("SourceGameId does not match")
			elseif RunService:IsStudio() or teleportData then
				TeleportHelper.SetJoinData(joinData2)
			else
				warn("No teleport data")
			end
		end)
		Players.PlayerRemoving:Connect(function(player)
			local userId = tostring(player.UserId)

			v2[userId] = nil
		end)

		TeleportService.TeleportInitFailed:Connect(function(p, p2, p3: string, p4: number, p5)
			TeleportHelper.Handle(p, p2, p3, p4, p5)
		end)
	else
		local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)

		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local v4 = { "Teleport" }

		RemoteSignals.OnClientEvent("Teleport", function(p: string, flag: boolean)
			if not table.find(v4, p) then
				return
			end

			print("Teleport: ", flag)

			Menu.CloseAll()

			if not flag then
				v.teleportUI = nil

				return
			end

			local clone = Assets.UI.TeleportUI:Clone()
			clone.Parent = playerGui
			v.teleportUI = clone
		end)

		TeleportService:SetTeleportGui(Assets.UI.TeleportUI:Clone())
	end
end

local function teleportStatus(items, teleporting: boolean)
	for _, item in items do
		local v4 = item and tostring(item)
		local character = item and item.Character

		if character then
			character:FindFirstChild("HumanoidRootPart")
		end

		v2[v4] = teleporting
		RemoteSignals.FireClient(item, "Teleport", "Teleport", teleporting)
		item:SetAttribute("Teleporting", teleporting)
	end
end

function TeleportHelper.SafeAsync(p: number, p2, p3)
	teleportStatus(p2, true)
	local count = 0
	local success, result

	repeat
		count += 1

		success, result = pcall(function()
			return TeleportService:TeleportAsync(p, p2, p3)
		end)

		if not success then
			task.wait(v3[Enum.TeleportResult.Failure])
		end
	until success or count == 5

	if not success then
		warn(result)
		teleportStatus(p2, false)
	end

	return result
end

function TeleportHelper.Handle(p, p2, p3, p4, p5)
	if not v3[p2] then
		warn(("Invalid teleport [%s]: %s"):format(p2.Name, p3))
		return
	end

	task.wait(v3[p2])

	TeleportHelper.SafeAsync(p4, { p }, p5)
end

function TeleportHelper:SetTeleportGui()
	TeleportService:SetTeleportGui(self)
end

function TeleportHelper.SetJoinData(p)
	joinData = p
	teleportData = p.TeleportData
end

function TeleportHelper.GetJoinData()
	return joinData
end

function TeleportHelper.GetTeleportData()
	return teleportData
end

return TeleportHelper