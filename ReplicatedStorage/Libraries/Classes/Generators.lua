local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local Generators = {}

function Generators.new(options, seed: number?)
	return {
		draw = {},
		list = options or {},
		previous = nil,
		seed = seed
	}
end

function Generators.Add(p, items, flag: boolean)
	for _, item in items do
		table.insert(p.list, item)

		if flag then
			table.insert(p.draw, item)
		end
	end
end

function Generators.Remove(p, items)
	for _, item in items do
		for _, list in { p.draw, p.list } do
			local index = table.find(list, item)

			if index then
				table.remove(list, index)
			end
		end
	end
end

function Generators:Get(seed: number?)
	if #self.draw == 0 then
		Generators.Reset(self)
	end

	if #self.draw == 0 then
		return
	end

	if seed then
		self.seed = seed
	end

	local integer = Random.new(self.seed):NextInteger(1, #self.draw)
	local previous = self.draw[integer]
	table.remove(self.draw, integer)

	self.previous = previous
	return previous
end

function Generators.Reset(data)
	if #data.list == 0 then
		warn("No list given to reload")
		return
	end

	for _, item in data.list do
		if data.previous ~= item or not (#data.list > 1) then
			table.insert(data.draw, item)
		end
	end
end

return Generators