local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local v = {
	Tier1 = "<font color='rgb(90, 92, 77)'>%s</font>",
	Tier2 = "<font color='rgb(144, 252, 3)'>%s</font>",
	Tier3 = "<font color='rgb(3, 123, 252)'>%s</font>",
	Tier4 = "<font color='rgb(190, 3, 252)'>%s</font>",
	Tier5 = "<font color='rgb(252, 227, 3)'>%s</font>",
	Tier6 = "<font color='rgb(200, 10, 10)'>%s</font>",
	Tier7 = "<i><b><font color='rgb(255, 0, 0)'>%s</font></b></i>",
	Tier8 = "<font color='rgb(255, 100, 10)'>%s</font>",
	Level100 = "<font color='rgb(236, 0, 253)'>%s</font>"
}

local v2 = {
	VIP = {
		owns = function(instance)
			return instance:GetAttribute("VIP")
		end,
		prefix = "<b><font color='#FFFF00'>[ VIP ]</font></b> "
	}
}

local ChatHelper = {}

function ChatHelper.Init()
	if isServer then
		return
	end

	local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)

	local userId = tostring(Players.LocalPlayer.UserId)

	TextChatService.OnIncomingMessage = function(data)
		local textSource = data.TextSource
		local textChatMessageProperties = Instance.new("TextChatMessageProperties")

		if string.sub(data.Text, 1, 1) == "!" then
			if
				string.lower(data.Text) == "!admin"
				and data.TextSource
				and tostring(data.TextSource.UserId) == userId
			then
				Menu.Open("Admin")
			end

			textChatMessageProperties.Text = " "
			return textChatMessageProperties
		elseif textSource then
			local userId2 = textSource and tostring(textSource.UserId)
			local playerByUserId = Players:GetPlayerByUserId((tonumber(userId2)))

			if not Profiles.GetPlayerReplica(userId2) then
				return
			end

			local v3 = ""

			for _, v4 in v2 do
				if v4.owns(playerByUserId) then
					v3 ..= v4.prefix
				end
			end

			textChatMessageProperties.PrefixText = v3 .. data.PrefixText
			return textChatMessageProperties
		else
			local metadata = data.Metadata

			if not v[metadata] then
				return nil
			end

			local v3 = v[metadata]
			textChatMessageProperties.Text = string.format(v3, data.Text)
			return textChatMessageProperties
		end
	end

	RemoteSignals.OnClientEvent(RemoteEnums.ChatAnnounce, function(...)
		local v3 = { ... }
		local v4 = v3[1]
		local v5 = v3[2]

		ChatHelper.ChatAnnounce(v4, v5)
	end)
end

function ChatHelper.ChatAnnounce(p, p2)
	if isServer then
		RemoteSignals.FireAllClients(RemoteEnums.ChatAnnounce, p, p2)
		return
	end

	local textChannels = TextChatService:FindFirstChild("TextChannels")
	local rbxGeneral = textChannels and textChannels:FindFirstChild("RBXGeneral")

	if not rbxGeneral then
		return
	end

	rbxGeneral:DisplaySystemMessage(p, p2)
end

return ChatHelper