local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
game:GetService("RunService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local userId = tostring(Players.LocalPlayer.UserId)

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
local v = Maid.new()
local event = bindableEvent2.Event
local event2 = bindableEvent.Event
local v2 = { Players, workspace, ReplicatedStorage }

local count = 0
local count2 = 0

local function update() -- 1 equivalent call inferred from this helper
	if count == count2 then
		bindableEvent:Fire()
	end
end

task.spawn(function()
	event2:Wait()
	RemoteSignals.FireServer(RemoteEnums.GeneralLoaded)
end)

for _, folder in v2 do
	for _, Script in folder:GetDescendants(), nil, nil do
		if not (Script:IsA("Script") or Script:IsA("ModuleScript")) then
			continue
		end

		local loaded = Script:GetAttribute("Loaded")

		if loaded == nil then
			continue
		end

		count += 1

		if loaded then
			count2 += 1
		else
			local v3 = Script
			v[Script.Name] = Script:GetAttributeChangedSignal("Loaded"):Connect(function()
				if v3:GetAttribute("Loaded") then
					count2 += 1
					v[v3.Name] = nil

					bindableEvent2:Fire()
				end
			end)
		end
	end
end

event:Connect(update)
update() -- inferred equivalent call