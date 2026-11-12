game:GetService("Players")

local bindableEvent = Instance.new("BindableEvent")

local buttons = {}

local MobileHelper = { ButtonCreated = bindableEvent.Event }

function MobileHelper.CreateButton(_, p, p2, p3, p4, p5, p6, p7: string?)
	local Button = require(script.Button)
	local button = Button.new(p2, p3, p4, p5, p6, p7)

	buttons[p] = button

	button.Destroyed:Connect(function()
		if buttons[p] then
			buttons[p] = nil
		end
	end)

	bindableEvent:Fire(p)

	return button
end

function MobileHelper:GetButton(p)
	return buttons[p]
end

function MobileHelper.GetButtonsById(_, items)
	local buttons2 = {}

	for k, _ in items do
		local button = MobileHelper:GetButton(k)

		if button then
			buttons2[k] = button
		end
	end

	return buttons2
end

function MobileHelper.GetButtons(_)
	return buttons
end

function MobileHelper.WaitForButton(_, p)
	local bindableEvent2 = Instance.new("BindableEvent")

	if MobileHelper:GetButton(p) then
		return buttons[p]
	end

	MobileHelper.ButtonCreated:Connect(function(p2)
		if p == p2 then
			bindableEvent2:Fire()
		end
	end)

	bindableEvent2.Event:Wait()
	return buttons[p]
end

return MobileHelper