local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local v = loaded("Blend")
local v2 = loaded("Maid")

return function(parent)
	local maid = v2.new()

	local state = v.State({ "a", "b", "c" })
	maid:GiveTask(state)

	maid:GiveTask(v.New("TextLabel")({
		Parent = parent,
		[v.Children] = {
			v.New("TextButton")({
				Text = "Add",
				AutoButtonColor = true,
				Size = UDim2.new(0, 100, 0, 20),
				[v.OnEvent("Activated")] = function()
					local v3 = {}

					for _, v4 in pairs(state.Value) do
						table.insert(v3, v4)
					end

					table.insert(v3, (string.char(#v3 + 97)))
					state.Value = v3
				end
			}),
			v.ComputedPairs(state, function(_, p)
				print("Compute", p)
				return v.New("TextLabel")({ Text = tostring(p), Size = UDim2.new(0, 20, 0, 20) })
			end),
			v.New("UIListLayout")({ Padding = UDim.new(0, 5) })
		}
	}):Subscribe())

	return function()
		maid:DoCleaning()
	end
end