local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local v = loaded("Maid")
local v2 = loaded("Observable")
local v3 = loaded("Blend")

return function(parent)
	local maid = v.new()

	local state = v3.State("a")

	maid:GiveTask(v3.Single(v3.Dynamic(state, function(text)
		return v3.New("TextLabel")({
			Parent = parent,
			Text = text,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0.5,
			[function()
				return v2.new(function()
					local maid2 = v.new()

					print("Made for", text)
					maid2:GiveTask(function()
						print("Cleaning up", text)
					end)

					return maid2
				end)
			end] = true
		})
	end)):Subscribe())

	state.Value = "b"

	return function()
		maid:DoCleaning()
	end
end