local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.Level)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Generators = require(ReplicatedStorage.Libraries.Classes.Generators)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(ReplicatedStorage.Types.Types)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()
local bindableEvent = Instance.new("BindableEvent")

local bindableEvent2 = Instance.new("BindableEvent")

local function now() -- 2 equivalent calls inferred from this helper
	return workspace:GetServerTimeNow()
end

local activeMission = nil
local flag = false

local function seasonField(p: string) -- 4 equivalent calls inferred from this helper
	local v = activeMission

	if v then
		return v[p]
	end

	return nil
end

local function dailyPointScale() -- 3 equivalent calls inferred from this helper
	return tonumber(seasonField("dailyPointScale")) or 1 -- inferred equivalent call
end

local function weeklyPointScale() -- 3 equivalent calls inferred from this helper
	return tonumber(seasonField("weeklyPointScale")) or 0.8 -- inferred equivalent call
end

local function questPoints(p: number, p2: number) -- 3 equivalent calls inferred from this helper
	return (math.max(5, math.floor(p * p2 / 5 + 0.5) * 5))
end

local function ladderScale() -- 3 equivalent calls inferred from this helper
	local v = seasonField("datastoreValue") -- inferred equivalent call
	return tonumber(v and v.ladderScale) or 1
end

local function previewSeasonName() -- 2 equivalent calls inferred from this helper
	if not RunService:IsStudio() then
		return nil
	end

	local previewSeason = ReplicatedStorage:GetAttribute("PreviewSeason")

	if typeof(previewSeason) == "string" and script.Events:FindFirstChild(previewSeason) then
		return previewSeason
	end

	return nil
end

local function loadSeason(eventModule) -- 3 equivalent calls inferred from this helper
	local module = require(eventModule)

	if eventModule.Name == previewSeasonName() then -- inferred equivalent call
		local eventStart = math.floor((workspace:GetServerTimeNow())) - 60

		if eventStart < module.eventStart then
			module.eventStart = eventStart
		end
	end

	return module
end

local function _getEventName()
	local previewSeason = previewSeasonName() -- inferred equivalent call

	if previewSeason then
		return previewSeason
	end

	local v = 0
	local name = nil

	for _, moduleScript in script.Events:GetChildren(), nil, nil do
		local module = require(moduleScript)

		if os.time() >= module.eventStart and v < module.eventEnd then
			v = module.eventEnd
			name = moduleScript.Name
		end

		if
			os.time() >= module.eventStart
			and os.time() < module.eventEnd
			and (not activeMission or module.eventName ~= activeMission.eventName)
		then
			return moduleScript.Name
		end
	end

	return name
end

local Events = { Changed = bindableEvent.Event, Ended = bindableEvent2.Event }

function Events.GetEventModule(childName: string?)
	return childName and script.Events:FindFirstChild(childName) or nil
end

function Events.Init()
	if flag then
		return
	end

	flag = true

	if isServer then
		task.spawn(function()
			local replica = Profiles.GetReplica("Game")

			while true do
				local eventName = _getEventName()
				local eventModule = Events.GetEventModule(eventName)

				if eventModule and eventName then
					local module = loadSeason(eventModule) -- inferred equivalent call
					local v = activeMission
					activeMission = module

					if replica.Data.currentEvent ~= eventName then
						replica:Write("CurrentEvent", eventName)
						RemoteSignals.FireAllClients("Events", "EventChange", eventName)
						bindableEvent:Fire()
					end

					if v and v.eventName ~= module.eventName then
						for _, v2 in Players:GetPlayers() do
							local v3 = v2
							task.spawn(function()
								local success, result = pcall(Events.Create, v3)

								if not success then
									warn(("Events: could not start %s's %s bucket: %s"):format(
										v3.Name,
										eventName,
										(tostring(result))
									))
								end
							end)
						end
					end
				end

				local v = not activeMission and 60 or activeMission.eventEnd - os.time() + 1

				task.wait(not (v > 0) and 60 or math.min(v, 60))
			end
		end)
	else
		local eventName = _getEventName()
		local eventModule = Events.GetEventModule(eventName)

		if eventModule and eventName then
			activeMission = loadSeason(eventModule) -- inferred equivalent call
		end

		task.spawn(function()
			RemoteSignals.OnClientEvent("Events", function(p, p2: string)
				if p == "EventChange" then
					local eventModule2 = Events.GetEventModule(p2)

					if not eventModule2 then
						return
					end

					activeMission = loadSeason(eventModule2) -- inferred equivalent call
					bindableEvent:Fire()
				end
			end)
		end)
	end

	task.defer(function()
		local eventName = nil

		while true do
			local v = activeMission

			if v then
				if Events:IsActive() then
					task.wait((math.clamp(Events:TimeLeft() + 0.05, 0.25, 30)))
					eventName = nil
				else
					if eventName ~= v.eventName then
						eventName = v.eventName
						bindableEvent2:Fire()
					end

					task.wait(30)
				end
			else
				task.wait(1)
			end
		end
	end)
end

Events.Init()

function Events:SyncMissions(p)
	if not (isServer and activeMission) then
		return
	end

	local eventDatastore = Events:GetEventDatastore(p, false)

	if not eventDatastore then
		return
	end

	local ladderScale2 = tonumber(eventDatastore.ladderScale) or 1

	if ladderScale2 ~= ladderScale() then -- inferred equivalent call
		local userId = tostring(p.UserId)
		local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
		local v2 = ladderScale() / ladderScale2 -- inferred equivalent call

		local v3 = {}

		for k, v4 in eventDatastore.battlepassClaims or {} do
			v3[k] = v4
		end

		for k in v3 do
			v:Write("EventClaims", k, nil)
		end

		for k, v4 in v3 do
			local v5 = tonumber(k)

			if v5 then
				v:Write("EventClaims", tostring((math.floor(v5 * v2 + 0.5))), v4)
			end
		end

		local progress = tonumber(eventDatastore.progress) or 0

		if progress > 0 then
			v:Write("EventProgress", math.floor(progress * v2 + 0.5) - progress)
		end

		v:Write("EventLadderScale", ladderScale()) -- inferred equivalent call
	end

	local set = {}

	for _, possibleMission in activeMission.possibleMissions do
		set[possibleMission.key] = true
	end

	local flag2 = false

	for _, v in eventDatastore.missions or {} do
		if not set[v.key] then
			flag2 = true
			break
		end
	end

	local missions = eventDatastore.missions

	if flag2 then
		Events:GenerateMissions(p)
	elseif typeof(missions) == "table" and #missions > 0 and #missions < 10 then
		Events:GenerateMissions(p, missions)
	end

	local weeklyQuests = eventDatastore.weeklyQuests
	local v = typeof(weeklyQuests) ~= "table" or #weeklyQuests == 0

	local v2 = not v and Events:CanRefreshWeekly(p) and true or v

	if not v2 then
		local set2 = {}

		for _, weeklyMission in activeMission.weeklyMissions do
			set2[weeklyMission.key] = true
		end

		for _, weeklyQuest in weeklyQuests do
			if not set2[weeklyQuest.key] then
				v2 = true
				break
			end
		end
	end

	if v2 then
		Events:GenerateWeeklyMissions(p)
	elseif #weeklyQuests < 15 then
		Events:GenerateWeeklyMissions(p, weeklyQuests)
	end

	Events:RepriceQuests(p)
end

function Events:RepriceQuests(p)
	if not isServer then
		return
	end

	local eventDatastore = Events:GetEventDatastore(p, false)

	if not eventDatastore then
		return
	end

	local userId = tostring(p.UserId)
	local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)

	for _, v2 in {
		{ name = "missions", write = "EventMissions", scale = dailyPointScale(), legacy = 1 }, -- inferred equivalent call
		{
			name = "weeklyQuests",
			write = "EventWeeklyMissions",
			scale = weeklyPointScale(), -- inferred equivalent call
			legacy = 0.8
		}
	} do
		local v3 = eventDatastore[v2.name]

		if typeof(v3) ~= "table" then
			continue
		end

		local clones = {}
		local flag2 = false

		for _, v4 in v3 do
			local clone = table.clone(v4)
			local pointScale = tonumber(v4.pointScale) or v2.legacy

			if pointScale ~= v2.scale then
				if not v4.claimed then
					clone.reward = questPoints((tonumber(v4.reward) or 0) / pointScale, v2.scale) -- inferred equivalent call
				end

				clone.pointScale = v2.scale
				flag2 = true
			end

			table.insert(clones, clone)
		end

		if flag2 then
			v:Write(v2.write, clones, true)
		end
	end
end

function Events.Create(p)
	if not isServer then
		return
	end

	if Events:GetEventDatastore(p, false) then
		Events:SyncMissions(p)

		return
	end

	local userId = tostring(p.UserId);
	(Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)):Write(
		"EventInit",
		(TableHelper:DeepCopy(activeMission.datastoreValue))
	)

	Events:GenerateMissions(p)
	Events:GenerateWeeklyMissions(p)
end

function Events.WaitForEventDatastore(_, p, value: number?)
	if not activeMission then
		return nil
	end

	local v = os.clock() + (value or 10)

	while os.clock() < v do
		local eventDatastore = Events:GetEventDatastore(p, false)

		if eventDatastore then
			return eventDatastore
		end

		task.wait()
	end

	warn(("Events: %s's event bucket never appeared"):format(p.Name))

	return nil
end

function Events.AddProgress(_, p, value: number)
	if not isServer or (typeof(value) ~= "number" or value <= 0) or not activeMission then
		return 0
	end

	if not Events:IsActive() then
		return 0
	end

	local userId = tostring(p.UserId)
	local playerReplica = Profiles.GetPlayerReplica(userId)

	if not (playerReplica and playerReplica:IsActive() and Events:GetEventDatastore(p, false)) then
		return 0
	end

	local v = math.floor(value)

	playerReplica:Write("EventProgress", v)

	return v
end

function Events:GetCurrencyInfo()
	local selected = seasonField("currency") -- inferred equivalent call
	return if typeof(selected) == "table" then selected else nil
end

function Events:GetCurrency(p)
	local eventDatastore = self:GetEventDatastore(p, false)

	return tonumber(eventDatastore and eventDatastore.currency) or 0
end

function Events:AddCurrency(p, value: number)
	if not isServer or (typeof(value) ~= "number" or value ~= value or value <= 0) then
		return 0
	end

	if not (self:GetCurrencyInfo() and self:IsActive()) then
		return 0
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(p.UserId)))

	if not (playerReplica and playerReplica:IsActive() and self:GetEventDatastore(p, false)) then
		return 0
	end

	local v = math.floor(value)

	if v <= 0 then
		return 0
	end

	playerReplica:Write("EventCurrency", v)

	return v
end

function Events:SpendCurrency(p, value: number): boolean
	if not isServer or (typeof(value) ~= "number" or value ~= value or value <= 0) then
		return false
	end

	if not (self:GetCurrencyInfo() and self:IsActive()) then
		return false
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(p.UserId)))

	if not (playerReplica and playerReplica:IsActive() and self:GetEventDatastore(p, false)) then
		return false
	end

	local v = math.ceil(value)

	if self:GetCurrency(p) < v then
		return false
	end

	playerReplica:Write("EventCurrency", -v)

	return true
end

function Events.CanRefreshMissions(_, p): boolean
	if not isServer then
		return false
	end

	local userId = tostring(p.UserId)

	if not Profiles.GetPlayerReplica(userId) then
		Profiles.WaitForPlayerReplica(userId)
	end

	Events:GetDatastoreKey()
	local eventDatastore = Events:GetEventDatastore(p, true)

	return not (os.time() - eventDatastore.lastMissionRefresh < activeMission.missionRefreshRate)
end

function Events:GenerateMissions(p, options)
	if not isServer then
		return
	end

	local userId = tostring(p.UserId)
	local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
	Events:GetDatastoreKey()

	if not self:GetEventDatastore(p, false) then
		return
	end

	local level = v.Data.level

	local set = {}

	for _, v2 in options or {} do
		set[v2.key] = true
	end

	local v2 = Generators.new()

	for k, possibleMission in activeMission.possibleMissions do
		local levelRequirement = possibleMission.levelRequirement
		local levelLimit = possibleMission.levelLimit

		if not (levelRequirement <= level) or not (level <= levelLimit) or set[possibleMission.key] then
			continue
		end

		Generators.Add(v2, { k })
	end

	local v3 = not options and {} or table.clone(options)

	if #v2.list == 0 then
		warn(("Events: no missions eligible for %s at level %d"):format(p.Name, level))
		return
	end

	local function generateMission(isSeasonPass)
		local v4 = Generators.Get(v2)

		if not v4 then
			return
		end

		local possibleMission = activeMission.possibleMissions[v4]

		if not possibleMission then
			return
		end

		local requirement = possibleMission.requirement()
		local reward = questPoints(possibleMission.reward(requirement), dailyPointScale()) -- inferred equivalent call

		local v5 = {
			key = possibleMission.key,
			description = possibleMission.description((tostring(requirement))),
			reward = reward,
			requirement = requirement,
			progress = 0,
			completed = false,
			claimed = false,
			isSeasonPass = isSeasonPass,
			pointScale = dailyPointScale() -- inferred equivalent call
		}
		table.insert(v3, v5)
	end

	while #v3 < 10 do
		local v4 = #v3

		generateMission(false)

		if #v3 == v4 then
			break
		end
	end

	v:Write("EventMissions", v3, options ~= nil)
end

function Events:GenerateWeeklyMissions(p, options)
	if not (isServer and activeMission) then
		return
	end

	local userId = tostring(p.UserId)
	local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)

	if not self:GetEventDatastore(p, false) then
		return
	end

	local level = v.Data.level
	local v2 = Generators.new()

	local set = {}

	for _, v3 in options or {} do
		set[v3.key] = true
	end

	for k, weeklyMission in activeMission.weeklyMissions do
		if
			not (weeklyMission.levelRequirement <= level)
			or not (level <= weeklyMission.levelLimit)
			or set[weeklyMission.key]
		then
			continue
		end

		Generators.Add(v2, { k })
	end

	if #v2.list == 0 then
		warn(("Events: no weekly missions eligible for %s at level %d"):format(p.Name, level))

		return
	end

	local v3

	if options then
		v3 = table.clone(options)
	else
		v3 = {}
	end

	while #v3 < 15 do
		local v4 = Generators.Get(v2)

		local v5 = v4 and activeMission.weeklyMissions[v4]

		if not v5 then
			break
		end

		local requirement = v5.requirement()

		local v6 = {
			key = v5.key,
			description = v5.description((tostring(requirement))),
			reward = questPoints(v5.reward(requirement), weeklyPointScale()), -- inferred equivalent call
			requirement = requirement,
			progress = 0,
			completed = false,
			claimed = false,
			isSeasonPass = false,
			pointScale = weeklyPointScale() -- inferred equivalent call
		}
		table.insert(v3, v6)
	end

	v:Write("EventWeeklyMissions", v3, options ~= nil)
end

function Events:GetClaimableQuests(p)
	local claimableQuests = {}

	if not self:IsActive() then
		return claimableQuests
	end

	local eventDatastore = self:GetEventDatastore(p, false)

	if not eventDatastore then
		return claimableQuests
	end

	for _, list in { "missions", "weeklyQuests" } do
		for k, v in eventDatastore[list] or {} do
			if not v.completed or v.claimed then
				continue
			end

			table.insert(claimableQuests, { list = list, index = k, reward = v.reward })
		end
	end

	return claimableQuests
end

function Events:IsQuestClaimable(p, p2: string, p3: number): boolean
	if not self:IsActive() then
		return false
	end

	local eventDatastore = self:GetEventDatastore(p, false)

	if not eventDatastore or p2 ~= "missions" and p2 ~= "weeklyQuests" then
		return false
	end

	local v = (eventDatastore[p2] or {})[p3]

	return not not v and not not v.completed and not v.claimed
end

function Events.GetMissionIndexByKey(_, p, p2: string, p3: string)
	local userId = tostring(p.UserId)

	if not Profiles.GetPlayerReplica(userId) then
		Profiles.WaitForPlayerReplica(userId)
	end

	Events:GetDatastoreKey()

	local missionIndex = {}

	for k, v in ({ Daily = Events:GetMissions(p), Weekly = Events:GetWeeklyMissions(p) })[p3] or {} do
		if v.key == p2 then
			table.insert(missionIndex, k)
		end
	end

	return missionIndex
end

function Events:OwnsSeasonPass(p): boolean
	local userId = tostring(p.UserId)

	for _, purchas in (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data.purchases do
		if not (purchas.timer and purchas.data and typeof(purchas.data) == "table" and purchas.data.data) then
			continue
		end

		if typeof(purchas.data.data) ~= "table" then
			continue
		end

		local v = purchas.data.data[1]

		local v2 = table.find(self:GetSeasonPassIds(), purchas.product) ~= nil

		if
			not v
			and purchas.timer > activeMission.eventStart
			and purchas.timer < activeMission.eventEnd
			and v2
			and purchas.bought
		then
			return true
		end
	end

	return false
end

function Events:IsActive(): boolean
	if not activeMission then
		return false
	end

	local v = now() -- inferred equivalent call
	return v <= activeMission.eventEnd and activeMission.eventStart <= v
end

function Events:TimeLeft()
	if activeMission then
		return activeMission.eventEnd - now() -- inferred equivalent call
	end

	return 0
end

function Events:MissionTimeLeft(p)
	local userId = tostring(p.UserId)

	if not Profiles.GetPlayerReplica(userId) then
		Profiles.WaitForPlayerReplica(userId)
	end

	Events:GetDatastoreKey()
	local eventDatastore = self:GetEventDatastore(p, true)

	local missionRefreshRate = activeMission.missionRefreshRate
	local lastMissionRefresh = eventDatastore.lastMissionRefresh

	return missionRefreshRate - (os.time() - lastMissionRefresh)
end

function Events:WeeklyTimeLeft(p)
	local eventDatastore = self:GetEventDatastore(p, true)

	return activeMission.weeklyRefreshRate - (os.time() - eventDatastore.lastWeeklyRefresh)
end

function Events:CanRefreshWeekly(p): boolean
	if isServer then
		return self:WeeklyTimeLeft(p) <= 0
	end

	return false
end

function Events.GetSeasonPassId(_): number
	return 3713641073
end

function Events.GetExclusiveSeasonPassId(_): number
	return 3713641133
end

function Events:GetSeasonPassIds()
	return { 3713641073, 3713641133 }
end

function Events:IsSeasonProduct(p: number): boolean
	return table.find(self:GetSeasonPassIds(), p) ~= nil
		or p == 3713656303
		or p == 3713656319
		or p == 3713656339
		or p == 3713656260
end

function Events.GetSkip1Id(_): number
	return 3713656303
end

function Events.GetSkip10Id(_): number
	return 3713656319
end

function Events.GetSkipAllId(_): number
	return 3713656339
end

function Events.GetRefreshId(_): number
	return 3713656260
end

function Events.GetActiveMission(_)
	return activeMission
end

function Events.GetSeasonName(_)
	return activeMission.eventName
end

function Events:GetDatastoreKey()
	return activeMission.datastoreKey
end

function Events:GetEventDatastore(p, flag2: boolean)
	local userId = tostring(p.UserId)
	local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
	local datastoreKey = Events:GetDatastoreKey()

	if flag2 then
		while not v.Data.events[datastoreKey] do
			task.wait()
		end
	end

	return v.Data.events[datastoreKey]
end

function Events:GetAbilitySpins(p)
	return self:GetEventDatastore(p, true).abilitySpins
end

function Events:GetMissions(p)
	return self:GetEventDatastore(p, true).missions
end

function Events:GetWeeklyMissions(p)
	return self:GetEventDatastore(p, true).weeklyQuests
end

function Events:GetBattlepassProgress(p)
	return self:GetEventDatastore(p, true).progress
end

function Events:GetBattlepassClaims(p)
	return self:GetEventDatastore(p, true).battlepassClaims
end

function Events:GetClaimableRewardCount(p)
	if not self:IsActive() then
		return 0
	end

	local eventDatastore = self:GetEventDatastore(p, false)

	if not eventDatastore then
		return 0
	end

	local progress = tonumber(eventDatastore.progress) or 0
	local battlepassClaims = eventDatastore.battlepassClaims or {}
	local ownsSeasonPass = self:OwnsSeasonPass(p)
	local count = 0

	for k in activeMission.rewards do
		local v = tonumber(k)

		if not (v and v <= progress) then
			continue
		end

		local battlepassClaim = battlepassClaims[k]
		local v2

		if battlepassClaim == nil then
			v2 = false
		else
			v2 = battlepassClaim.free and (not ownsSeasonPass or battlepassClaim.season)
		end

		if not v2 then
			count += 1
		end
	end

	return count
end

function Events:GetBattlepassRewards()
	return activeMission.rewards
end

function Events.GetBundles(_)
	return activeMission.bundles
end

function Events.GetLowestPoints(_)
	local lowestPoints = 1e999

	for k, _ in activeMission.rewards do
		local v = tonumber(k)

		if v < lowestPoints then
			lowestPoints = tonumber(v)
		end
	end

	return lowestPoints
end

function Events.GetHighestPoints(_)
	local highestPoints = 0

	for k, _ in activeMission.rewards do
		local v = tonumber(k)

		if highestPoints < v then
			highestPoints = tonumber(v)
		end
	end

	return highestPoints
end

function Events.GetBetweenRewards(_, p, p2)
	local v = {}

	for k, _ in Events:GetBattlepassRewards(), nil, nil do
		table.insert(v, (tonumber(k)))
	end

	local v2, v3 = TableHelper[p2](TableHelper, v, Events:GetBattlepassProgress(p))

	return v2, v3
end

return Events