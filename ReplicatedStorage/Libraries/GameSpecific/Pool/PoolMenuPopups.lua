local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Events = require(ReplicatedStorage.Libraries.Modules.Events)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolGalaxyPopup = require(Pool.PoolGalaxyPopup)
local PoolGalaxySet = require(Pool.PoolGalaxySet)
local PoolJoinSource = require(Pool.PoolJoinSource)
local PoolSeasonPrompt = require(Pool.PoolSeasonPrompt)
local PoolSkins = require(Pool.PoolSkins)
local PoolStarterPackCard = require(Pool.PoolStarterPackCard)
local PoolStarterPackPopup = require(Pool.PoolStarterPackPopup)
local PoolTutorialPopup = require(Pool.PoolTutorialPopup)
local PoolDailyRewardsPopup = require(Pool.PoolDailyRewardsPopup)
local PoolEventFeatures = require(Pool.PoolEventFeatures)
local PoolSeasonHype = require(Pool.PoolSeasonHype)

local PoolMenuPopups = {}

local v = nil

local v2 = nil

local v3 = nil

local v4 = nil

local v5 = {}

local function define(p) -- 5 equivalent calls inferred from this helper
	assert(not v5[p.Id], "PoolMenuPopups: duplicate popup id " .. p.Id)
	v5[p.Id] = p
end

local POOL_STARTER_PACK_INFO = MonetizationConstants.POOL_STARTER_PACK_INFO

define({ -- inferred equivalent call
	Id = "StarterPack",
	IsEligible = function()
		return PoolStarterPackCard.CanBuy()
	end,
	Show = function()
		if v then
			PoolStarterPackPopup.Show(v)
		end
	end,
	IsShowing = function()
		return v ~= nil and PoolStarterPackPopup.IsVisible(v)
	end
})

define({ -- inferred equivalent call
	Id = "GalaxySet",
	IsEligible = function(): boolean
		if not PoolGalaxySet.HasStock() then
			return false
		end

		local localPlayer = Players.LocalPlayer

		if not localPlayer then
			return false
		end

		for _, tier in PoolGalaxySet.Tiers do
			local isSoldOut = PoolGalaxySet.IsSoldOut(tier.Id)
			local owns = PoolSkins.Owns(localPlayer.UserId, PoolGalaxySet.Category, tier.Item)

			if not (isSoldOut or owns) then
				return true
			end
		end

		return false
	end,
	Show = function()
		if v2 then
			PoolGalaxyPopup.Show(v2)
		end
	end,
	IsShowing = function()
		return v2 ~= nil and PoolGalaxyPopup.IsVisible(v2)
	end
})

define({ -- inferred equivalent call
	Id = "SeasonPass",
	IsEligible = function(): boolean
		local localPlayer = Players.LocalPlayer

		if not localPlayer then
			return false
		end

		if Events:IsActive() then
			return not Events:OwnsSeasonPass(localPlayer)
		end

		return false
	end,
	Show = function()
		if v3 then
			PoolSeasonPrompt.Show(v3)
		end
	end,
	IsShowing = function()
		return v3 ~= nil and PoolSeasonPrompt.IsVisible(v3)
	end
})

define({ -- inferred equivalent call
	Id = "SeasonHype",
	IsEligible = function()
		local localPlayer = Players.LocalPlayer

		return localPlayer ~= nil and v4 ~= nil and PoolEventFeatures.HypePending(localPlayer)
	end,
	Show = function()
		if v4 then
			PoolSeasonHype.Show(v4)
		end
	end,
	IsShowing = function()
		return v4 ~= nil and PoolSeasonHype.IsVisible(v4)
	end
})

define({ -- inferred equivalent call
	Id = "DailyReward",
	IsEligible = function()
		return PoolDailyRewardsPopup.CanClaim()
	end,
	Show = function()
		PoolDailyRewardsPopup.Show()
	end,
	IsShowing = function()
		return PoolDailyRewardsPopup.IsVisible()
	end
})

local v6 = { "SeasonHype", "SeasonPass", "GalaxySet" }

local v7 = {}

local v8 = { "DailyReward" }

for _, v9 in { v6, v7, v8 } do
	for _, v10 in v9 do
		if not v5[v10] then
			warn("[PoolMenuPopups] no popup defined for id " .. v10)
		end
	end
end

local random = Random.new()

local function isEligible(p) -- 4 equivalent calls inferred from this helper
	local success, result = pcall(p.IsEligible)

	if not success then
		warn(string.format("[PoolMenuPopups] %s IsEligible errored: %s", p.Id, (tostring(result))))
	end

	return success and result == true
end

function PoolMenuPopups.Pick()
	for _, v9 in v6 do
		local v10 = v5[v9]

		if v10 and isEligible(v10) then -- inferred equivalent call
			return v10
		end
	end

	local v9 = {}
	local total = 0

	for _, v10 in v7 do
		local v11 = v5[v10]
		local v12 = v11 and math.max(tonumber(v11.Weight) or 1, 0) or 0

		if not (v11 and v12 > 0 and isEligible(v11)) then -- inferred equivalent call
			continue
		end

		table.insert(v9, v11)
		total += v12
	end

	if total <= 0 then
		return nil
	end

	local v10 = random:NextNumber() * total

	for _, v11 in v9 do
		v10 -= math.max(tonumber(v11.Weight) or 1, 0)

		if v10 <= 0 then
			return v11
		end
	end

	return v9[#v9]
end

local v9 = nil
local v10 = nil
local flag = false

function PoolMenuPopups.BindStarterPack(p)
	v = p

	p.Confirmed:Connect(function()
		PoolStarterPackPopup.Hide(p)
		PoolStarterPackCard.Prompt()
	end)

	p.Declined:Connect(function()
		PoolStarterPackPopup.Hide(p)
	end)
end

function PoolMenuPopups.ShowStarterPack(): boolean
	if v and PoolStarterPackCard.CanBuy() then
		PoolStarterPackPopup.Show(v)

		return true
	end

	return false
end

function PoolMenuPopups.BindSeasonPrompt(p)
	v3 = p

	p.Dismissed:Connect(function()
		local galaxySet = v5.GalaxySet

		if galaxySet and isEligible(galaxySet) and galaxySet.Show then -- inferred equivalent call
			galaxySet.Show()
		end
	end)
end

function PoolMenuPopups.BindGalaxySet(p)
	v2 = p
end

function PoolMenuPopups.BindSeasonHype(p)
	v4 = p
end

local function customShowing(): boolean
	for _, v11 in v5 do
		if not v11.IsShowing then
			continue
		end

		local success, result = pcall(v11.IsShowing)

		if success and result then
			return true
		end
	end

	return false
end

function PoolMenuPopups.AnyShowing()
	if v10 or v9 and PoolTutorialPopup.IsVisible(v9) then
		return true
	end

	return customShowing()
end

function PoolMenuPopups.Bind(p)
	v9 = p

	p.Confirmed:Connect(function()
		local v11 = v10

		v10 = nil
		PoolTutorialPopup.Hide(p)

		if v11 and v11.OnConfirm then
			task.spawn(v11.OnConfirm)
		end
	end)

	p.Declined:Connect(function()
		v10 = nil
		PoolTutorialPopup.Hide(p)
	end)
end

local function completedIntroduction(): boolean -- 1 equivalent call inferred from this helper
	local localPlayer = Players.LocalPlayer
	local v11 = localPlayer and Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))
	local tutorials = v11 and v11.Data and v11.Data.tutorials

	return typeof(tutorials) == "table" and tutorials.Introduction ~= nil and tutorials.Introduction ~= false
end

function PoolMenuPopups.OnJoin(callback)
	if flag then
		return
	end

	flag = true

	if not v9 then
		warn("[PoolMenuPopups] OnJoin called before Bind")

		return
	end

	if not completedIntroduction() then -- inferred equivalent call
		return
	end

	local lastTime = os.clock()

	task.spawn(function()
		if not PoolJoinSource.IsFromHome() then
			return
		end

		task.wait(1.5)

		while os.clock() - lastTime <= 60 do
			local v11 = v9
			local success, result = pcall(callback)

			if success and result and not (v10 or PoolTutorialPopup.IsVisible(v11) or customShowing()) then
				local v12 = PoolMenuPopups.Pick()

				if v12 and v12.Show then
					v12.Show()
				elseif v12 and v12.Build then
					v10 = v12
					PoolTutorialPopup.Show(v11, v12.Build())
				end

				PoolMenuPopups.ShowAfter(callback, lastTime)
				break
			end

			task.wait(0.5)
		end
	end)
end

function PoolMenuPopups.ShowAfter(callback, p: number)
	task.spawn(function()
		local v11 = nil

		while os.clock() - p <= 300 do
			local v12 = v9
			local success, result = pcall(callback)

			if success and result and not v10 and not (PoolTutorialPopup.IsVisible(v12) or customShowing()) then
				v11 = v11 or os.clock()

				if os.clock() - v11 >= 0.8 then
					for _, v13 in v8 do
						local v14 = v5[v13]

						if v14 and v14.Show and isEligible(v14) then -- inferred equivalent call
							v14.Show()

							return
						end
					end

					break
				end
			else
				v11 = nil
			end

			task.wait(0.2)
		end
	end)
end

return PoolMenuPopups