local parent = script.Parent
local reward1 = parent.Parent.Reward1

local function update() -- 1 equivalent call inferred from this helper
	parent.Text = reward1.Text
end

update() -- inferred equivalent call
reward1:GetPropertyChangedSignal("Text", update)