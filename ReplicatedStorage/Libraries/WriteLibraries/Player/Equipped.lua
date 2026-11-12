local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StringHelper = require(ReplicatedStorage.Libraries.Helpers.StringHelper)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryTypes)
require(ReplicatedStorage.Types.DataTypes)

RunService:IsServer()

return function(p, p2: string, p3: string)
	local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
	local ownsItem = InventoryHelpers.OwnsItem(p.Tags.Player, p2, p3)
	local v = StringHelper.RemovePlural(p2)

	if not ownsItem then
		warn("Player doesn't own item")
		return
	end

	local _data = p.Data

	if typeof(p.Data.equipped[p2]) ~= "table" then
		p.Data.equipped[v] = p3

		return
	end

	local v2 = p.Data.equipped[p2]

	if table.find(v2, p3) then
		table.remove(v2, table.find(v2, p3))
	elseif p2 == "emotes" and #p.Data.equipped.emotes >= 8 then
		warn("Player can only equip 8 emotes")
	else
		table.insert(v2, p3)
	end
end