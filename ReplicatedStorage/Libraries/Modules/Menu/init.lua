local Players = game:GetService("Players")
game:GetService("StarterGui")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("Lighting")
require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Classes.Maid)
local MenuConstants = require(script.MenuConstants)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")

local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = false

local Menu = { Opened = bindableEvent.Event, Closed = bindableEvent2.Event }

local function _getMenuConfig(p: string) -- 1 equivalent call inferred from this helper
	return MenuConstants[p] or { exclusive = true, closes = nil }
end

function Menu.IsOpen(p: string): boolean
	return v[p] ~= nil
end

function Menu.GetOpenMenus()
	local openMenus = {}

	for k in v do
		table.insert(openMenus, k)
	end

	return openMenus
end

function Menu.CloseSpecific(p: string)
	if not v[p] then
		return
	end

	local child = PlayerGui:FindFirstChild(p .. "UI")

	if child then
		child.Enabled = false
	end

	v[p] = nil

	for _, v6 in v4 do
		v6()
	end

	bindableEvent2:Fire(p)
end

function Menu.CloseAll()
	local openMenus = Menu.GetOpenMenus()

	for _, v6 in openMenus do
		Menu.CloseSpecific(v6)
	end
end

function Menu.Open(p: string, submenu: string?, ...)
	if v5 or not p then
		return
	end

	local child = PlayerGui:WaitForChild(p .. "UI")

	if not child then
		return
	end

	local menuConfig = _getMenuConfig(p) -- inferred equivalent call

	if v[p] then
		v[p] = { submenu = submenu }
	else
		if menuConfig.exclusive then
			local openMenus = Menu.GetOpenMenus()

			for _, v6 in openMenus do
				Menu.CloseSpecific(v6)
			end
		end

		if menuConfig.closes then
			for _, clos in menuConfig.closes do
				if Menu.IsOpen(clos) then
					Menu.CloseSpecific(clos)
				end
			end
		end

		v[p] = { submenu = submenu }

		child.Enabled = true
		table.insert(v2, { p, submenu, ... })

		for _, v6 in v3 do
			v6()
		end
	end

	bindableEvent:Fire(p, submenu, ...)
end

function Menu.Close(p: string?)
	if not p then
		return
	end

	Menu.CloseSpecific(p)
end

function Menu.PromptSequence(items)
	for _, item in items do
		local menu = item.menu
		local submenu = item.submenu

		if not item.requirement() then
			continue
		end

		Menu.Open(menu, submenu)
		Menu.Closed:Wait()
	end
end

function Menu.GetMenu()
	for i = #v2, 1, -1 do
		local v6 = v2[i][1]

		if typeof(v6) == "string" and v[v6] then
			return v6
		end
	end

	return nil
end

function Menu.GetPrevious()
	return v2[#v2 - 1]
end

function Menu.FunctionOnOpen(p)
	table.insert(v3, p)
end

function Menu.FunctionOnClose(p)
	table.insert(v4, p)
end

function Menu.Lock(flag: boolean)
	v5 = flag
end

return Menu