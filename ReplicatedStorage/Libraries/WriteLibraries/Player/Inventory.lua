game:GetService("ReplicatedStorage")
game:GetService("RunService")

return function(p, p2, p3, p4)
	local _player = p.Tags.Player

	if p.Data.inventory[p2] then
		p.Data.inventory[p2][p3] = p4
	else
		warn("Category: " .. p2 .. " not found in the inventory datastore key")
	end
end