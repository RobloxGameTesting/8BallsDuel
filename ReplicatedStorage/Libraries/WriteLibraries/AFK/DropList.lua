local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, p2: string, p3)
	local dropList = p.Data.dropList

	if not dropList[p2] then
		dropList[p2] = {}
	end

	table.insert(dropList[p2], p3)
end