local v = { "You can find the codes in the store menu" }

local Tip = script.Parent.Frame.Tip

local function getTipIndex() -- 2 equivalent calls inferred from this helper
	return math.floor(os.time() / 5) % #v + 1
end
Tip.Text = v[getTipIndex()] -- inferred equivalent call

task.spawn(function()
	local v2 = nil

	while Tip.Parent do
		local tipIndex = getTipIndex() -- inferred equivalent call

		if tipIndex ~= v2 then
			Tip.Text = v[tipIndex]
			v2 = tipIndex
		end

		task.wait(0.25)
	end
end)