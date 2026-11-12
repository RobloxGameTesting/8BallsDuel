local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local userId = tostring(Players.LocalPlayer.UserId)

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

Maid.new()
local music = SoundService.Music

local v = nil

local Music = {}

function Music:Play(value: number?)
	if self == v then
		return
	end

	if v then
		Music.Stop(v, value)
	end

	v = self

	local child = music:FindFirstChild(self)
	local volume = child and child:GetAttribute("Volume")

	if child and child:GetAttribute("Restart") then
		child.TimePosition = 0
	end

	TweenService:Create(child, TweenInfo.new(value or 0.5), { Volume = volume }):Play()
end

function Music.Stop(childName: string?, value: number?)
	if not childName then
		return
	end

	TweenService:Create(music:FindFirstChild(childName), TweenInfo.new(value or 0.5), { Volume = 0 }):Play()
	v = nil
end

return Music