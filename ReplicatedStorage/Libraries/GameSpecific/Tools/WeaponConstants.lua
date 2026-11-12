game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return { AUTO_ROTATE_ON_EQUIP = true, SERVER_VALIDATION_PERCENT = 0.8 }