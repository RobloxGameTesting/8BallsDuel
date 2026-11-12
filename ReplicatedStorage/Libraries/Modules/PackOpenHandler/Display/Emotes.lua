local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent.Parent)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local Players = game:GetService("Players")
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)

local userId = tostring(Players.LocalPlayer.UserId)

return function(p)
	if not p then
		warn("No reward passed")
		return
	end

	local displayMaid = parentModule.GetDisplayMaid()
	local itemData = InventoryHelpers.GetItemData("Emotes", p.item)
	InventoryHelpers.GetItemColour("Emotes", p.item)
	local clone = (ReplicatedStorage.Assets.CachedCharacters:FindFirstChild(userId) or ReplicatedStorage.Assets.EmoteRig):Clone()
	clone.PrimaryPart.Anchored = true
	clone:ScaleTo(0.2)
	parentModule.AddToViewport(clone)
	clone.Parent = workspace
	parentModule.ApplyOutline(clone)

	task.spawn(function()
		while clone and clone:IsDescendantOf(workspace) do
			ModelHelper.CanCollide(clone, false)
			task.wait()
		end
	end)

	local animator = clone:FindFirstChild("Animator", true)
	local v = Animations.new({ idle = itemData.animationId }, animator)

	Animations.Play(v, {
		{ animation = "idle", fadeIn = 0, looped = true }
	})

	function displayMaid.display()
		print("Clearing animation")
		Animations.Destroy(v)
		clone:Destroy()
	end
end