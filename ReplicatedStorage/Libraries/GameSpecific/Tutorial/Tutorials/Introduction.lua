local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

require(ReplicatedStorage.Libraries.GameSpecific.Tutorial.TutorialTypes)

local v = { "Accepted the tutorial", "Aimed at the 8 ball", "Took the shot", "Potted the 8 ball" }

if RunService:IsServer() then
	return v
end

local PoolTutorialFlow = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTutorialFlow)

return {
	{
		name = "Offer",
		message = "",
		guidance = {},
		startFunction = function()
			PoolTutorialFlow.StartOffer()
		end,
		target = {
			call = "Function",
			values = {
				func = function()
					return PoolTutorialFlow.OfferAnswered()
				end
			}
		},
		endFunction = function()
			PoolTutorialFlow.EndOffer()
		end
	},
	{
		name = "Aim",
		message = "",
		guidance = {},
		startFunction = function()
			PoolTutorialFlow.StartAim()
		end,
		target = {
			call = "Function",
			values = {
				func = function()
					return PoolTutorialFlow.AimIsValid()
				end
			}
		},
		endFunction = function()
			PoolTutorialFlow.EndAim()
		end
	},
	{
		name = "Power",
		message = "",
		guidance = {},
		startFunction = function()
			PoolTutorialFlow.StartPower()
		end,
		target = {
			call = "Function",
			values = {
				func = function()
					return PoolTutorialFlow.ShotTaken()
				end
			}
		},
		endFunction = function()
			PoolTutorialFlow.EndPower()
		end
	},
	{
		name = "Watch the pot",
		message = "",
		guidance = {},
		startFunction = function()
			PoolTutorialFlow.StartWatch()
		end,
		target = {
			call = "Function",
			values = {
				func = function()
					return PoolTutorialFlow.EightPotted()
				end
			}
		},
		endFunction = function()
			PoolTutorialFlow.EndWatch()
		end
	}
}