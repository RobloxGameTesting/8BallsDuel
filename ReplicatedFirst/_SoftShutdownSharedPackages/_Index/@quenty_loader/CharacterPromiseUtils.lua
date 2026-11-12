local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Maid")
local v2 = loaded("Promise")

return {
	promiseCharacter = function(player)
		assert(typeof(player) == "Instance", "Bad player")

		local v3 = v2.new()

		if player.Character then
			v3:Resolve(player.Character)
			return v3
		end

		local maid = v.new()

		maid:GiveTask(player.CharacterAdded:Connect(function(character)
			v3:Resolve(character)
		end))

		v3:Finally(function()
			maid:DoCleaning()
		end)

		return v3
	end
}