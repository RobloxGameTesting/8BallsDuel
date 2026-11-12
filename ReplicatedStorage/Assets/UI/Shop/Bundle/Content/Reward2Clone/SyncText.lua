local parent = script.Parent
local reward2 = parent.Parent.Reward2

local function update() -- 1 equivalent call inferred from this helper
	parent.Text = reward2.Text
end

update() -- inferred equivalent call
reward2:GetPropertyChangedSignal("Text", update)