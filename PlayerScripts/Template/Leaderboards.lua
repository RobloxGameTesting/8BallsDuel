local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)

local replica = Profiles.GetReplica("Leaderboard")
local leaderboards = workspace.Leaderboards
local GlobalLeaderboardLabel = ReplicatedStorage.Assets.UI.Leaderboard.GlobalLeaderboardLabel
local v = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 255, 255)
}

local v2 = {}
local childNames = {}

local function update(childName, items)
	print("Updating the leaderboard", replica.Data)

	if not v2[childName] then
		v2[childName] = Maid.new()
	end

	local v3 = v2[childName]
	local surfaceGui = leaderboards:FindFirstChild(childName).LeaderboardHolder.SurfaceGui

	if not table.find(childNames, childName) then
		UserInterfaceHelper:FitScrollingFrame(surfaceGui.GlobalList, "Y", UDim2.new(0, 0, 0, 5))
		table.insert(childNames, childName)
	end

	for k, _ in v3._tasks do
		if not items[k] then
			v3[k] = nil
		end
	end

	for k, item in items do
		local folder = v3[k] or GlobalLeaderboardLabel:Clone()
		local placement = item.placement
		folder.LayoutOrder = placement
		folder.Rank.Text = `# {placement}`
		folder.Username.Text = item.username
		folder.Name = item.username

		for _, label in folder:GetDescendants(), nil, nil do
			if label:IsA("TextLabel") then
				label.TextColor3 = v[math.clamp(placement, 1, 4)]
			end
		end

		folder.Value.Text = item.value
		folder.Parent = surfaceGui.GlobalList
		v3[k] = folder
	end
end

replica:ListenToWrite("UpdateGlobalLeaderboard", update)