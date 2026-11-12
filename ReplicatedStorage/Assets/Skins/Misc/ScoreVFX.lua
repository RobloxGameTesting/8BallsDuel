local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local scoreVFX = ReplicatedStorage.Assets.Skins.ScoreVFX
local ScoreVFX = {}
ScoreVFX.name = "ScoreVFX"
ScoreVFX.itemType = "ScoreVFX"

function ScoreVFX.image(p, _)
	local module = require(scoreVFX:FindFirstChild(p.scoreVFXName))

	return module.image()
end

function ScoreVFX.labelTop(p, _)
	local module = require(scoreVFX:FindFirstChild(p.scoreVFXName))
	return module.name
end

function ScoreVFX.labelBottom(_, _): string
	return "ScoreVFX"
end

function ScoreVFX.rarity(p, p2)
	local module = require(scoreVFX:FindFirstChild(p.scoreVFXName))

	return module.rarity(p, p2)
end

return ScoreVFX