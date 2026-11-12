local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local LoadingScreen = require(script.Parent:WaitForChild("LoadingScreen"))

local LocalPlayer = Players.LocalPlayer
local v = LoadingScreen.new()
local skip = v.Skip

v.DisplayOrder = 2147483647
v.Parent = LocalPlayer.PlayerGui

local ui = ReplicatedStorage:WaitForChild("UI")
local SoundEffects = SoundService:WaitForChild("SoundEffects")
local Assets = script.Assets

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local children = ui:GetChildren()

for _, child in children do
	child.Parent = LocalPlayer.PlayerGui
end

local childAddedConnection = ui.ChildAdded:Connect(function(child)
	warn("[LoadGui] " .. child.Name .. " replicated after game.Loaded; forwarding it")

	child.Parent = LocalPlayer.PlayerGui
end)

local children2 = { v, Assets, SoundEffects }

for _, child in children do
	table.insert(children2, child)
end

local bindableEvent = Instance.new("BindableEvent")

local v2 = false

task.spawn(function()
	local count = 0

	while not v2 do
		count += 1
		v.Timer.Text = count

		if count >= 10 then
			skip.Visible = true
		end

		task.wait(1)
	end
end)

skip.Button.Activated:Connect(function()
	bindableEvent:Fire()
end)

task.spawn(function()
	ContentProvider:PreloadAsync(children2)
	bindableEvent:Fire()
end)

task.delay(30, function()
	if not v2 then
		warn("[LoadGui] preloading did not finish within " .. 30 .. "s; continuing without it")
	end

	bindableEvent:Fire()
end)

bindableEvent.Event:Wait()

SoundEffects.Volume = 0.5

childAddedConnection:Disconnect()

local ClientEvents = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Modules"):WaitForChild("ClientEvents"))
ClientEvents.GameFinishedLoad:Fire()

local v3 = false
local activatedConnection = skip.Button.Activated:Connect(function()
	v3 = true
end)

local lastTime = os.clock()
local v4 = lastTime + 90
local v5 = nil
local v6 = false
local v7 = false

while not v3 and os.clock() < v4 do
	v5 = v5 or LocalPlayer.PlayerGui:FindFirstChild("PoolMenuUI")

	if v5 and v5:GetAttribute("Ready") then
		v6 = true
		break
	end

	if not v7 and os.clock() - lastTime >= 15 then
		warn("[LoadGui] PoolMenuUI not Ready after " .. 15 .. "s; still waiting (player data is most likely still loading)")
		v7 = true
	end

	task.wait(0.05)
end

activatedConnection:Disconnect()

if not (v6 or v3) then
	warn("[LoadGui] PoolMenuUI never reported Ready within " .. 90 .. "s; clearing the loading screen anyway")
end

v2 = true
v:Destroy()