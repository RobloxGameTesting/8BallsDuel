local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Modules.Profiles)

return {
	GetValue = function(instance, childName: string)
		local leaderstats = instance:FindFirstChild("leaderstats")

		if leaderstats then
			return (leaderstats:FindFirstChild(childName))
		end

		return nil
	end
}