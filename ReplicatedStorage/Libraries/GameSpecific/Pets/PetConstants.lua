game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return {
	GENDER_ICONS = { Female = "rbxassetid://87053736543043", Male = "rbxassetid://90833164291412" },
	TYPE_ICONS = {
		Normal = "rbxassetid://90833164291412",
		Fire = "rbxassetid://90833164291412",
		Water = "rbxassetid://90833164291412",
		Ice = "rbxassetid://90833164291412",
		Electric = "rbxassetid://90833164291412",
		Rock = "rbxassetid://90833164291412",
		Grass = "rbxassetid://90833164291412"
	}
}