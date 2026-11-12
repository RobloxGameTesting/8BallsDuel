local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
require(ReplicatedStorage.Libraries.Modules.Scheduler)

local LocalPlayer = Players.LocalPlayer

local references = {}

local Dialog = { ReferenceAdded = Instance.new("BindableEvent") }

function Dialog.Triggered(p)
	if Menu.IsOpen("Dialog") then
		return
	end

	Menu.Open("Dialog", p)
end

function Dialog.AddReference(p)
	table.insert(references, p)
	Dialog.ReferenceAdded:Fire(p)
end

function Dialog.RemoveReference(p)
	local index = table.find(references, p)

	if index then
		table.remove(references, index)
	end
end

function Dialog.GetReferences()
	return references
end

return Dialog