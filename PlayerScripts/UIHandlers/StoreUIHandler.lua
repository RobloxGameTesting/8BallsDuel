local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local storeUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StoreUI")
local store = storeUI.Background.Content.Store
local flipKeyValue = TableHelper.FlipKeyValue(MonetizationConstants.PRODUCT_IDS.CURRENCY1_RATES)

local function init()
	for _, child in store.Coins:GetChildren(), nil, nil do
		if flipKeyValue[tonumber(child.Name)] then
			child.Name = flipKeyValue[tonumber(child.Name)]
		end
	end
end

init()

UserInterfaceHelper:FitScrollingFrame(storeUI.Background.Content.Store, "Y", UDim2.fromOffset(0, 10))