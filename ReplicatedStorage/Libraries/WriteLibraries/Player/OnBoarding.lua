local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, p2)
	if not table.find(p.Data.onBoarding, p2) then
		table.insert(p.Data.onBoarding, p2)
	end
end