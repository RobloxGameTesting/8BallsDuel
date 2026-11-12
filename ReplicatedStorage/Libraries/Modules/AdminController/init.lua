local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(script.AdminTypes)
local AdminConstants = require(script.AdminConstants)
local Players = game:GetService("Players")
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
local MessagingService = game:GetService("MessagingService")
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local HttpService = game:GetService("HttpService")

local isServer = RunService:IsServer()
local Commands = script.Commands
local v = Maid.new()

local moduleScriptsByName = {}
local modulesByName = {}
local v2 = {}
local flag = false

local function _lastCommandTime(p: string) -- 2 equivalent calls inferred from this helper
	local v3 = 0

	for _, v4 in v2[p] do
		if v3 < v4 then
			v3 = v4
		end
	end

	return v3
end

local AdminController = {}

local function _initPlayer(parent)
	local userId = tostring(parent.UserId)
	v2[userId] = {}

	if isServer then
		if AdminConstants.ADMIN_USER_IDS[userId] then
			parent:SetAttribute("AdminRole", "OwnerAdmin")
		else
			parent:SetAttribute("AdminRole", nil)
		end

		local products = Instance.new("Folder")
		products.Name = "Products"
		products.Parent = parent

		for _, name in AdminConstants.PRODUCT_IDS do
			local folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = products
		end
	end
end

local function _initCommandModules()
	for _, moduleScript in Commands:GetChildren(), nil, nil do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		moduleScriptsByName[moduleScript.Name] = moduleScript
		local name = moduleScript.Name
		local module = require(moduleScript)
		modulesByName[name] = module
	end
end

local function _initServerRemotes()
	RemoteSignals.OnServerEvent(RemoteEnums.Admin, function(p, p2: string, p3)
		local userId = tostring(p.UserId)

		AdminController.Request(userId, p2, p3)
	end)

	local success, result = pcall(function()
		return MessagingService:SubscribeAsync("AdminCommand", function(p)
			local jsonDecode = HttpService:JSONDecode(p.Data)
			local u = jsonDecode.u
			local c = jsonDecode.c
			local o = jsonDecode.o

			if Players:GetPlayerByUserId(u) then
				return
			end

			AdminController.Request(u, c, o)
		end)
	end)

	if not success then
		warn(result)
	end
end

function AdminController.Init()
	if flag then
		return
	end

	flag = true

	for _, v3 in Players:GetPlayers(), nil, nil do
		_initPlayer(v3)
	end

	Players.PlayerAdded:Connect(_initPlayer)
	Players.PlayerRemoving:Connect(function(player)
		local userId = tostring(player.UserId)
		v2[userId] = nil
	end)

	_initCommandModules()

	if isServer then
		_initServerRemotes()
	end
end

function AdminController.Request(p: string?, p2: string, p3)
	if not AdminController.CanUse(p, p2, p3) then
		return
	end

	local v3 = AdminController.GetModules()[p2]
	print("Request: ", p, p2, HttpService:JSONEncode(p3))

	if p then
		if v2[p] then
			v2[p][p2] = tick()
		end

		if isServer then
			local success, result = pcall(function()
				return v3.onActivate(p, p3)
			end)

			if not success then
				error(result)
			end

			local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))

			if playerByUserId then
				AnalyticsService:LogCustomEvent(playerByUserId, "Command Used", 1, {
					[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = `Command: {p2}`
				})
			end

			if not AdminConstants.SILENT_COMMANDS then
				RemoteSignals.FireAllClients("Notification", "Notification", "KillFeedNotification", {
					message = result,
					audio = { "Abilities", "Time Controller" },
					length = 4
				})
			end

			if v3.commandType == "Global" and playerByUserId then
				local success2, result2 = pcall(function()
					MessagingService:PublishAsync("AdminCommand", HttpService:JSONEncode({
						u = p,
						c = p2,
						o = p3
					}))
				end)

				if not success2 then
					warn(result2)
				end
			end
		else
			local success, result = pcall(function()
				return v3.onActivate(p, p3)
			end)

			if not success then
				error(result)
			end

			RemoteSignals.FireServer(RemoteEnums.Admin, p2, p3)
		end
	else
		local success, result = pcall(function()
			return v3.onActivate(nil, p3)
		end)

		if not success then
			error(result)
		end
	end
end

function AdminController.CanUse(p: string?, p2, p3): boolean
	if not p or AdminConstants.ADMIN_USER_IDS[p] then
		return true
	end

	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))

	if not playerByUserId then
		return false
	end

	local products = playerByUserId:FindFirstChild("Products")
	local adminRole = playerByUserId:GetAttribute("AdminRole")
	local playerReplica = Profiles.GetPlayerReplica(p)
	local v3 = AdminController.GetModules()[p2]
	local flag2 = true

	if not playerReplica then
		warn("No replica found")
		return false
	end

	if not playerReplica:IsActive() then
		warn("Replica is not active")
		return false
	end

	if not v3 then
		warn(`Admin command: {p2} doesn't exist`)
		return false
	end

	if not products then
		warn("No products folder found in player")
		return false
	end

	if not adminRole then
		warn("Player doesn't have any admin role")
		return false
	end

	if table.find(v3.userIds, p) then
		return true
	end

	if #v3.robuxIds > 0 then
		flag2 = false

		for _, child in products:GetChildren(), nil, nil do
			local name = child.Name

			if name and table.find(v3.robuxIds, name) then
				flag2 = true
				break
			end
		end
	end

	if _lastCommandTime(p) and tick() - _lastCommandTime(p) < AdminConstants.COOLDOWN then -- inferred equivalent call
		warn(`{AdminConstants.COOLDOWN}s cooldown hasn't elapsed`)
		return false
	end

	if flag2 then
		if not table.find(v3.roles, adminRole) then
			warn("Player doesn't have the role required to perform this action")
			return false
		end

		if AdminController.IsCooldown(p, p2) then
			if not isServer then
				local v4 = {
					message = `Command is on cooldown ({math.ceil(v3.cooldown - (tick() - v2[p][p2]))}s)`,
					parent = "TopNotificationLabel",
					length = 4
				}

				Notifications.new("TextNotification", v4)
				warn(`{p2} cooldown of {v3.cooldown}s hasn't elapsed`)
			end

			return false
		end

		if p3 then
			for k, option in v3.options do
				if option.optionType == "List" and not table.find(option.extra, p3[k]) then
					return false
				end
			end
		end

		return true
	end

	warn("Player doesn't own the needed Robux product")
	Sales.Prompt(p, tonumber(v3.robuxIds[1]), Enum.InfoType.Product)
	return false
end

function AdminController.GetModuleScripts()
	return moduleScriptsByName
end

function AdminController.GetModules()
	return modulesByName
end

function AdminController.IsAdmin(p): boolean
	return Players:GetPlayerByUserId(p):GetAttribute("AdminRole") ~= nil
end

function AdminController.IsCooldown(p: string, p2: string): boolean
	local v3 = AdminController.GetModules()[p2]

	if not (Profiles.GetPlayerReplica(p) or Profiles.WaitForPlayerReplica(p)).Data.gamepasses.NoCooldown then
		local _cooldown = v3.cooldown
	end

	local v4 = v2[p]
	local v5 = v4 and v4[p2]

	if not v4 then
		return true
	end

	if v5 then
		return tick() - v5 < v3.cooldown
	end

	return false
end

function AdminController.AddToMaid(p)
	v[p] = p
end

function AdminController.ClearMaid()
	v:Destroy()
end

return AdminController