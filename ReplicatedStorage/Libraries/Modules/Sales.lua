local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)
local PlayerHelpers = require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(ReplicatedStorage.Libraries.Classes.Sounds)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()
local v = { "Sales", "SalesGiftId" }

local v2 = {}

local v3 = {}
local v4 = {}

local Sales = {}

function Sales.Init()
	if isServer then
		RemoteSignals.OnServerEvent("Sales", function(p, p2: string, value: number, ...)
			if not table.find(v, p2) then
				return
			end

			local v5 = { ... }
			local userId = tostring(p.UserId)

			if p2 == "Sales" then
				Sales.Set(p, value, false, ...)
			elseif p2 == "SalesGiftId" then
				local v6

				if (typeof(value) == "string" or typeof(value) == "number") and tonumber(value) then
					v6 = tostring(value)
				end

				local v7

				if typeof(v5[1]) == "number" then
					v7 = v5[1]
				end

				Sales.SetGiftId(userId, v6, false, v7)
			end
		end)

		Players.PlayerRemoving:Connect(function(player)
			local userId = tostring(player.UserId)

			Sales.Set(player, nil, false)
			Sales.SetGiftId(userId, nil, false)
		end)
	else
		local localPlayer = Players.LocalPlayer
		local userId = tostring(localPlayer.UserId)

		RemoteSignals.OnClientEvent("Sales", function(p, ...)
			if not table.find(v, p) then
				return
			end

			local v5 = { ... }

			if p == "Sales" then
				local v6 = v5[1]

				Sales.Set(localPlayer, v6, false, ...)
			elseif p == "SalesGiftId" then
				Sales.SetGiftId(userId, v5[1], false, v5[2])
			end
		end)
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, _, _)
		Sales.Set(p, nil, false)
	end)

	MarketplaceService.PromptPurchaseFinished:Connect(function(p, _, _)
		Sales.Set(p, nil, false)
	end)

	MarketplaceService.PromptBundlePurchaseFinished:Connect(function(p, _, _)
		Sales.Set(p, nil, false)
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, _, _)
		local playerByUserId = p and Players:GetPlayerByUserId(p)

		Sales.Set(playerByUserId, nil, false)
	end)
end

function Sales.Prompt(p: string, p2: number, p3, p4: string?, ...)
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))

	if not playerByUserId then
		return
	end

	if p3 == Enum.InfoType.Product then
		local Events = require(ReplicatedStorage.Libraries.Modules.Events)
		local success, result = pcall(function()
			return Events:IsSeasonProduct(p2) and not Events:IsActive()
		end)

		if success and result then
			warn("[Sales] the season has ended; not prompting product " .. tostring(p2))

			return
		end
	end

	if p4 then
		Sales.SetGiftId(p, p4, true, p2)
	else
		Sales.SetGiftId(p, nil, true)
	end

	Sales.Set(playerByUserId, p2, true, ...)

	local success, result = pcall(function()
		if p3 == Enum.InfoType.GamePass then
			MarketplaceService:PromptGamePassPurchase(playerByUserId, p2)
		elseif p3 == Enum.InfoType.Product then
			MarketplaceService:PromptProductPurchase(playerByUserId, p2)
		end
	end)

	if not success then
		Sales.Set(playerByUserId, nil, false)
		error(result)
	end
end

function Sales.Set(p, id: number?, flag: boolean, ...)
	local userId = tostring(p.UserId)

	if v4[userId] and id or not (v4[userId] or id) then
		return
	end

	if id then
		v4[userId] = {
			id = id,
			data = { ... }
		}
	else
		v4[userId] = nil
	end

	if isServer then
		if flag then
			RemoteSignals.FireClient(p, "Sales", "Sales", id, ...)
		end
	else
		local saleUI = p.PlayerGui.SaleUI

		if flag then
			RemoteSignals.FireServer("Sales", "Sales", id, ...)
		end

		task.spawn(function()
			if v4[userId] == nil then
				TweenService:Create(saleUI.Frame, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
				TweenService:Create(saleUI.Frame.Shadow, TweenInfo.new(0.5), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(saleUI.Frame.GiftLabel, TweenInfo.new(0.25), {
					Position = UDim2.new(0.5, 0, 1.1, 0)
				}):Play()
				task.wait(0.5)

				if v4[userId] == nil then
					saleUI.Frame.Visible = false
				end
			else
				saleUI.Frame.BackgroundTransparency = 1
				saleUI.Frame.Visible = true

				TweenService:Create(saleUI.Frame, TweenInfo.new(0.5), {
					BackgroundTransparency = 0.5
				}):Play()

				local v5 = tonumber(v4[userId].data[1])
				local playerByUserId = v5 and Players:GetPlayerByUserId(v5)

				if playerByUserId then
					TweenService:Create(saleUI.Frame.Shadow, TweenInfo.new(0.5), {
						BackgroundTransparency = 0
					}):Play()
					saleUI.Frame.GiftLabel.Position = UDim2.new(0.5, 0, 1.1, 0)
					TweenService:Create(saleUI.Frame.GiftLabel, TweenInfo.new(1), {
						Position = UDim2.new(0.5, 0, 0.9, 0)
					}):Play()
					saleUI.Frame.GiftLabel.Text = "GIFTING: " .. string.upper(PlayerHelpers.GetName(playerByUserId))
				else
					saleUI.Frame.GiftLabel.Position = UDim2.new(0.5, 0, 1.1, 0)
				end
			end
		end)
	end
end

function Sales.Get(p: string)
	return v4[p]
end

function Sales.GetGiftId(p: string)
	return v2[p]
end

function Sales.GetGiftIdFor(p: string, p2: number)
	local v5 = v2[p]

	return if not (v5 == nil or v3[p] ~= p2) then v5 else nil
end

function Sales.SetGiftId(p: string, p2: string?, flag: boolean, p3: number?)
	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))

	if isServer then
		if flag and playerByUserId then
			RemoteSignals.FireClient(playerByUserId, "Sales", "SalesGiftId", p2, p3)
		end
	elseif flag then
		RemoteSignals.FireServer("Sales", "SalesGiftId", p2, p3)
	end

	v2[p] = p2
	local v5 = v3

	if p2 == nil then
		p3 = nil
	end

	v5[p] = p3
end

function Sales.PromptGift(p: string, p2: number, p3: string)
	return Sales.Prompt(p, p2, Enum.InfoType.Product, p3, p3)
end

return Sales