local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local KeybindImages = require(ReplicatedStorage.Assets.Images.KeybindImages)
local MobileControlImages = require(ReplicatedStorage.Assets.Images.MobileControlImages)
local ConsoleKeybindImages = require(ReplicatedStorage.Assets.Images.ConsoleKeybindImages)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local connections = Maid.new()
local v = {
	["0"] = "Zero",
	["1"] = "One",
	["2"] = "Two",
	["3"] = "Three",
	["4"] = "Four",
	["5"] = "Five",
	["6"] = "Six",
	["7"] = "Seven",
	["8"] = "Eight",
	["9"] = "Nine"
}

local v2 = { keyCode = {}, userInputType = {}, mobile = {} }

UserInputService.InputBegan:Connect(function(input, _)
	local value = input.KeyCode.Value
	local value2 = input.UserInputType.Value

	local v3 = v2.keyCode[value] or v2.userInputType[value2]

	if not v3 then
		return
	end

	for _, v4 in v3 do
		if not v4:FindFirstChild("Icon") then
			continue
		end

		TweenService:Create(v4.Icon, TweenInfo.new(0.1), { Size = UDim2.new(0.8, 0, 0.8, 0) }):Play()
		v4.Icon.ImageColor3 = Color3.fromRGB(190, 190, 190)
	end
end)

UserInputService.InputEnded:Connect(function(input, _)
	local value = input.KeyCode.Value
	local value2 = input.UserInputType.Value

	local v3 = v2.keyCode[value] or v2.userInputType[value2]

	if not v3 then
		return
	end

	for _, v4 in v3 do
		TweenService:Create(v4.Icon, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 1, 0) }):Play()
		v4.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end
end)
local function addKeybind(descendant)
	if not (descendant:FindFirstChild("Icon") and descendant:GetAttribute("Keybind")) then
		return
	end

	local v3 = descendant:GetAttribute("Keybind")
	local v4, v5

	if string.find(v3, "Mobile") then
		v4 = v3
		v5 = "mobile"
	else
		local success, _ = pcall(function(): boolean
			v3 = v[v3] or v3

			return if Enum.KeyCode[v3] then true else false
		end)

		if success then
			v4 = Enum.KeyCode[v3].Value
			v5 = "keyCode"
		else
			v4 = Enum.UserInputType[v3].Value
			v5 = "userInputType"
		end
	end

	if not v2[v5][v4] then
		v2[v5][v4] = {}
	end

	for _, v6 in v2 do
		for _, list in v6 do
			for k, item in list do
				if item == descendant then
					TweenService:Create(item.Icon, TweenInfo.new(0.1), {
						Size = UDim2.new(1, 0, 1, 0)
					}):Play()
					item.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

					table.remove(list, k)
					break
				end
			end
		end
	end

	table.insert(v2[v5][v4], descendant)

	descendant.Icon.Image = KeybindImages[v4] or MobileControlImages[v4] or ConsoleKeybindImages[v4]

	connections[descendant] = descendant:GetAttributeChangedSignal("Keybind"):Connect(function()
		descendant:GetAttribute("Keybind")
		addKeybind(descendant)
	end)
end

local function removeKeybind(p)
	for _, v3 in v2 do
		for _, list in v3 do
			for k, item in list do
				if item == p then
					table.remove(list, k)
					break
				end
			end
		end
	end
end

PlayerGui.DescendantRemoving:Connect(removeKeybind)
PlayerGui.DescendantAdded:Connect(addKeybind)

for _, descendant in PlayerGui:GetDescendants(), nil, nil do
	addKeybind(descendant)
end