local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Modules.Menu)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
local PolicyServiceHelper = require(ReplicatedStorage.Libraries.Helpers.PolicyServiceHelper)
local Inventories = require(ReplicatedStorage.Libraries.Classes.Inventories)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local rightPanel1 = PlayerGui:WaitForChild("MainUI"):WaitForChild("RightPanel1")
local userId = tostring(LocalPlayer.UserId)
local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data
local StarterPackPromptUI = PlayerGui:WaitForChild("StarterPackPromptUI")
local Background = StarterPackPromptUI.Background
local productId = MonetizationConstants.STARTER_PACK_INFO.productId
local v = PolicyServiceHelper:Get(LocalPlayer)
local OffsaleLabel = Background.OffsaleLabel

Button.Create(Background.Buy, function()
	Sales.Set(LocalPlayer, productId, true)
	MarketplaceService:PromptProductPurchase(LocalPlayer, productId)
	Sounds.Play(Sounds.new({ "UserInterface", "Transactions", "Starterpack" }, nil), nil, true)
end)

pcall(function()
	MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
end)
StarterPackPromptUI.Background.RobuxOption.Robux.Text = tostring(MonetizationConstants.STARTER_PACK_INFO.originalCost[v.ArePaidRandomItemsRestricted])

for _, v2 in MonetizationConstants.STARTER_PACK_INFO.rewards[v.ArePaidRandomItemsRestricted] do
	Inventories.fromList({ Key = v2 }, StarterPackPromptUI.Background.Rewards, "misc", "v1")
end

while true do
	local v2 = MonetizationConstants.STARTER_PACK_INFO.timeLimit - (os.time() - data.firstPlay)

	if v2 <= 0 then
		OffsaleLabel.Text = "PACK INCLUDES"
		rightPanel1.StarterPackPrompt.Visible = false
	else
		local formatTimerHMS = NumberHelper.FormatTimerHMS(v2)
		OffsaleLabel.Text = "OFFSALE IN " .. formatTimerHMS
		rightPanel1.StarterPackPrompt.Visible = true
		rightPanel1.StarterPackPrompt.Content.Timer.Text = formatTimerHMS

		if v2 / MonetizationConstants.STARTER_PACK_INFO.timeLimit < 0.5 then
			rightPanel1.StarterPackPrompt.Content.Timer.TextColor3 = Color3.fromRGB(255, 0, 0)
		else
			rightPanel1.StarterPackPrompt.Content.Timer.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	task.wait(1)
end