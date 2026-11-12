game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return { PREVENT_GROUPING = true, BILLBOARD_BOSS_HEALTH = true, SCREEN_BOSS_HEALTH = false }