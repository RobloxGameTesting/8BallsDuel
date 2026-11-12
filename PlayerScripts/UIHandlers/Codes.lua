local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
require(ReplicatedStorage.Types.NotificationTypes)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

local content = PlayerGui:WaitForChild("StoreUI").Background.Content.Store.Codes.Content
local textbox = content.InputFrame.Textbox
local redeem = content.Redeem
local v = { "Code" }

Button.Create(redeem, function()
	local text = string.lower(textbox.Text)

	if string.len(text) == 0 then
		return
	end

	RemoteSignals.FireServer("Codes", "Code", text)
	textbox.Text = ""
end)

RemoteSignals.OnClientEvent("Codes", function(p, ...)
	if not table.find(v, p) then
		return
	end

	local v2 = { ... }
	local v3 = v2[1]
	local message = v2[2]

	textbox.Text = ""

	if v3 then
		print(v3)
	else
		Notifications.new("TextNotification", { message = message, length = 3 })
	end
end)