local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local CameraHelper = require(ReplicatedStorage.Libraries.Helpers.CameraHelper)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

local isServer = RunService:IsServer()

local v = {}

return {
	command = "Poop",
	commandType = "Server",
	searchTerms = { "Poop" },
	icon = "rbxassetid://86657214676131",
	layoutOrder = 10,
	maxActivationDistance = 1e999,
	cooldown = 15,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.Troll },
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		if not isServer then
			return ""
		end

		local item = list[1]

		local playerByUserId = Players:GetPlayerByUserId(item)
		local character = playerByUserId and playerByUserId.Character

		if character then
			character:FindFirstChildWhichIsA("Humanoid")
		end

		if v[item] then
			return "Player is already pooping"
		end

		v[item] = true

		task.spawn(function()
			local clone = script.Toilet:Clone()
			local clone2 = CharacterHelper.Clone(character)
			local forceField = clone2:FindFirstChildWhichIsA("ForceField")

			if forceField then
				forceField:Destroy()
			end

			ModelHelper.Invisible(character)
			clone:PivotTo(character.PrimaryPart.CFrame)
			clone.Parent = workspace
			clone2.Parent = workspace
			task.spawn(function()
				clone2.ModelStreamingMode = Enum.ModelStreamingMode.PersistentPerPlayer
				clone2:AddPersistentPlayer(playerByUserId)
				CameraHelper.SetSubject(playerByUserId, clone2:WaitForChild("Head"))
			end)
			local clones = Maid.new()
			local humanoid = clone2:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				clone.Seat:Sit(humanoid)
			end

			for i = 0, 12 do
				task.wait((math.clamp((12 - i) / 8, 0.1, 10)))
				local clone3 = script.Poop:Clone()
				clone3.CFrame = clone.PrimaryPart.CFrame
				clone3.Parent = workspace
				Sounds.Play(Sounds.new({ "AdminAbuseSounds", "Fart" }, clone3), nil, true)
				clones[i] = clone3
				clone.PrimaryPart.CFrame *= CFrame.new(0, 0.9, 0)
			end

			Sounds.Play(Sounds.new({ "AdminAbuseSounds", "GIGA FART" }, clone.PrimaryPart.Position), nil, true)
			local explosion = Instance.new("Explosion")
			explosion.Position = clone.PrimaryPart.Position + Vector3.new(
				Random.new():NextNumber(-1, 1),
				Random.new():NextNumber(-1, 1),
				Random.new():NextNumber(-1, 1)
			)
			explosion.Parent = workspace

			task.wait(Players.RespawnTime)
			explosion:Destroy()
			clone:Destroy()
			clones:Destroy()
			clone2:Destroy()
			v[item] = nil

			CameraHelper.SetSubject(playerByUserId, character:FindFirstChildWhichIsA("Humanoid"))
			ModelHelper.Visible(character)
		end)

		return `Admin pooped <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
	end
}