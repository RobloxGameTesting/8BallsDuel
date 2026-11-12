local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local v = loaded("Maid")
local v2 = loaded("SoftShutdownTranslator")
local v3 = loaded("SoftShutdownUI")
local v4 = loaded("ServiceBag")

return function(parent)
	local maid = v.new()
	local v5 = v4.new()
	maid:GiveTask(v5)

	local service = v5:GetService(v2)

	local v6 = v3.new()
	maid:GiveTask(v6)

	maid:GiveTask(service:ObserveFormatByKey("shutdown.lobby.title"):Subscribe(function(p)
		v6:SetTitle(p)
	end))

	maid:GiveTask(service:ObserveFormatByKey("shutdown.lobby.subtitle"):Subscribe(function(p)
		v6:SetSubtitle(p)
	end))

	v6:Show()

	v6.Gui.Parent = parent

	return function()
		maid:DoCleaning()
	end
end