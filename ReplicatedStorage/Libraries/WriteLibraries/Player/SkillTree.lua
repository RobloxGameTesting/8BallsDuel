return function(p, p2)
	if not table.find(p.Data.skillTree, p2) then
		table.insert(p.Data.skillTree, p2)
	end
end